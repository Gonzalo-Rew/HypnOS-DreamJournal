import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart' as model;
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';

/// Repository for authentication operations
abstract class AuthRepository {
  /// Sign up with email and password
  Future<Result<void>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with email and password
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  /// Sign out
  Future<Result<void>> signOut();

  /// Delete account after password re-authentication.
  Future<Result<void>> deleteAccountWithPassword({required String password});

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email});

  /// Get current user
  Future<Result<model.User>> getCurrentUser();

  /// Listen to auth state changes
  Stream<model.User?> authStateChanges();

  /// Sign in with Google
  Future<Result<void>> signInWithGoogle();

  /// Sign in with Apple
  Future<Result<void>> signInWithApple();

  /// Update user profile
  Future<Result<void>> updateUserProfile({
    String? displayName,
    String? photoUrl,
    bool? aiEnabled,
    String? timezone,
    bool? notificationsEnabled,
    String? notificationTime,
  });
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore;

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    fa.User? createdAuthUser;
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        throw ValidationException(message: 'All fields are required');
      }

      if (password.length < 8) {
        throw ValidationException(
          message: 'Password must be at least 8 characters',
          field: 'password',
        );
      }

      final nameKey = displayName.trim().toLowerCase();

      // Create user account
      final userCredential = await FirebaseService.auth
          .createUserWithEmailAndPassword(email: email, password: password);
      createdAuthUser = userCredential.user;

      // Update display name in Firebase Auth
      await createdAuthUser?.updateDisplayName(displayName.trim());

      final uid = createdAuthUser!.uid;
      final userRef = _firestore.collection('users').doc(uid);
      final usernameRef = _firestore.collection('usernames').doc(nameKey);

      // Atomically claim the username + create user document
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(usernameRef);
        if (snap.exists) {
          throw ValidationException(
            message: 'display_name_taken',
            field: 'displayName',
          );
        }
        final user = model.User(
          id: uid,
          email: email,
          displayName: displayName.trim(),
          createdAt: DateTime.now(),
          aiEnabled: true,
          timezone: 'UTC',
          notificationsEnabled: true,
          notificationTime: '08:00',
        );
        tx.set(usernameRef, {'uid': uid, 'displayName': displayName.trim()});
        tx.set(userRef, user.toFirestore());
      });

      return const Success(null);
    } on ValidationException catch (e) {
      // Clean up auth user if we already created it before the race condition
      await createdAuthUser?.delete();
      if (e.message == 'display_name_taken') {
        return Failure(
          ValidationException(
            message: 'display_name_taken',
            field: 'displayName',
          ),
        );
      }
      return Failure(AuthException(message: e.message));
    } on fa.FirebaseAuthException catch (e) {
      return Failure(
        AuthException(message: _getAuthErrorMessage(e.code), code: e.code),
      );
    } catch (e) {
      await createdAuthUser?.delete();
      debugPrint('[Auth] signUp error: $e');
      return Failure(
        AuthException(message: 'auth-generic', code: 'auth-generic'),
      );
    }
  }

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ValidationException(message: 'Email and password are required');
      }

      await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return const Success(null);
    } on fa.FirebaseAuthException catch (e) {
      var normalizedCode = _normalizeSignInErrorCode(e);
      if (normalizedCode == 'invalid-credential') {
        normalizedCode = await _resolveInvalidCredentialCode(email: email);
      }
      return Failure(
        AuthException(
          message: _getAuthErrorMessage(normalizedCode),
          code: normalizedCode,
        ),
      );
    } catch (e) {
      debugPrint('[Auth] signIn error: $e');
      return Failure(
        AuthException(message: 'auth-generic', code: 'auth-generic'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await FirebaseService.auth.signOut();
      return const Success(null);
    } catch (e) {
      debugPrint('[Auth] signOut error: $e');
      return Failure(
        AuthException(message: 'Sign out failed. Please try again.'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccountWithPassword({
    required String password,
  }) async {
    try {
      final currentUser = FirebaseService.auth.currentUser;
      if (currentUser == null) {
        return Failure(
          AuthException(message: 'no-current-user', code: 'no-current-user'),
        );
      }

      final trimmedPassword = password.trim();
      if (trimmedPassword.isEmpty) {
        return Failure(
          ValidationException(message: 'password_required', field: 'password'),
        );
      }

      final email = currentUser.email;
      if (email == null || email.isEmpty) {
        return Failure(
          AuthException(
            message: 'password-reauth-unavailable',
            code: 'password-reauth-unavailable',
          ),
        );
      }

      final credential = fa.EmailAuthProvider.credential(
        email: email,
        password: trimmedPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);

      final uid = currentUser.uid;
      final userRef = _firestore.collection('users').doc(uid);

      await _firestore.runTransaction((tx) async {
        final userSnap = await tx.get(userRef);

        final displayNameFromUserDoc =
            userSnap.data()?['displayName'] as String? ?? '';
        final fallbackDisplayName = currentUser.displayName ?? '';
        final nameKey =
            (displayNameFromUserDoc.isNotEmpty
                    ? displayNameFromUserDoc
                    : fallbackDisplayName)
                .trim()
                .toLowerCase();

        if (nameKey.isNotEmpty) {
          final usernameRef = _firestore.collection('usernames').doc(nameKey);
          final usernameSnap = await tx.get(usernameRef);
          if (usernameSnap.exists) {
            final reservedUid = usernameSnap.data()?['uid'] as String?;
            if (reservedUid == uid) {
              tx.delete(usernameRef);
            }
          }
        }

        tx.delete(userRef);
      });

      await currentUser.delete();
      return const Success(null);
    } on fa.FirebaseAuthException catch (e) {
      return Failure(
        AuthException(message: _getAuthErrorMessage(e.code), code: e.code),
      );
    } on FirebaseException catch (e) {
      return Failure(
        AuthException(message: e.message ?? 'firestore-failed', code: e.code),
      );
    } catch (e) {
      debugPrint('[Auth] deleteAccountWithPassword error: $e');
      return Failure(
        AuthException(message: 'auth-generic', code: 'auth-generic'),
      );
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      if (email.isEmpty) {
        throw ValidationException(message: 'Email is required');
      }

      await FirebaseService.auth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on fa.FirebaseAuthException catch (e) {
      return Failure(
        AuthException(message: _getAuthErrorMessage(e.code), code: e.code),
      );
    } catch (e) {
      debugPrint('[Auth] passwordReset error: $e');
      return Failure(
        AuthException(message: 'Password reset failed. Please try again.'),
      );
    }
  }

  @override
  Future<Result<model.User>> getCurrentUser() async {
    try {
      final currentUser = FirebaseService.getCurrentUser();
      if (currentUser == null) {
        throw AuthException(message: 'No user logged in');
      }

      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        throw AuthException(message: 'User document not found');
      }

      return Success(model.User.fromFirestore(doc.data()!, doc.id));
    } catch (e) {
      return Failure(AuthException(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Stream<model.User?> authStateChanges() {
    return FirebaseService.authStateChanges().asyncMap((authUser) async {
      if (authUser == null) {
        return null;
      }

      final doc = await _firestore.collection('users').doc(authUser.uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return model.User.fromFirestore(doc.data()!, doc.id);
    });
  }

  @override
  Future<Result<void>> updateUserProfile({
    String? displayName,
    String? photoUrl,
    bool? aiEnabled,
    String? timezone,
    bool? notificationsEnabled,
    String? notificationTime,
  }) async {
    try {
      final currentUser = FirebaseService.getCurrentUser();
      if (currentUser == null) {
        throw AuthException(message: 'No user logged in');
      }

      if (notificationTime != null &&
          !_isValidNotificationTime(notificationTime)) {
        throw ValidationException(
          message: 'notificationTime must follow HH:mm format',
          field: 'notificationTime',
        );
      }

      // ── Handle displayName uniqueness ────────────────────────────────────
      if (displayName != null) {
        final newKey = displayName.trim().toLowerCase();

        // Fetch the current displayName to know the old key
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        final oldName = userDoc.data()?['displayName'] as String? ?? '';
        final oldKey = oldName.toLowerCase();

        if (newKey != oldKey) {
          // Check availability + atomically swap reservations
          await _firestore.runTransaction((tx) async {
            final newRef = _firestore.collection('usernames').doc(newKey);
            final snap = await tx.get(newRef);
            if (snap.exists &&
                (snap.data()?['uid'] as String?) != currentUser.uid) {
              throw ValidationException(
                message: 'display_name_taken',
                field: 'displayName',
              );
            }
            // Release old reservation only when it belongs to the current user.
            if (oldKey.isNotEmpty) {
              final oldRef = _firestore.collection('usernames').doc(oldKey);
              final oldSnap = await tx.get(oldRef);
              if (oldSnap.exists &&
                  (oldSnap.data()?['uid'] as String?) == currentUser.uid) {
                tx.delete(oldRef);
              }
            }
            // Claim new name only when reservation does not already exist.
            if (!snap.exists) {
              tx.set(newRef, {
                'uid': currentUser.uid,
                'displayName': displayName.trim(),
              });
            }
          });
        }

        await currentUser.updateDisplayName(displayName.trim());
      }

      if (photoUrl != null) {
        await currentUser.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName.trim();
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (aiEnabled != null) updateData['aiEnabled'] = aiEnabled;
      if (timezone != null) updateData['timezone'] = timezone;
      if (notificationsEnabled != null) {
        updateData['notificationsEnabled'] = notificationsEnabled;
      }
      if (notificationTime != null) {
        updateData['notificationTime'] = notificationTime;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update(updateData);
      }

      return const Success(null);
    } on ValidationException catch (e) {
      if (e.message == 'display_name_taken') {
        return Failure(
          ValidationException(
            message: 'display_name_taken',
            field: 'displayName',
          ),
        );
      }
      return Failure(AuthException(message: e.message));
    } catch (e) {
      debugPrint('[Auth] updateUserProfile error: $e');
      return Failure(
        AuthException(message: 'Profile update failed. Please try again.'),
      );
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      // Sign out first to always show the account picker
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled — not an error
        return const Success(null);
      }
      final googleAuth = await googleUser.authentication;
      final credential = fa.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseService.auth.signInWithCredential(
        credential,
      );
      await _ensureUserDocument(userCredential.user!);
      return const Success(null);
    } on fa.FirebaseAuthException catch (e) {
      return Failure(
        AuthException(message: _getAuthErrorMessage(e.code), code: e.code),
      );
    } on PlatformException catch (e) {
      final code = _getGooglePlatformErrorCode(e);
      return Failure(AuthException(message: code, code: code));
    } catch (e) {
      debugPrint('[Auth] signInWithGoogle error: $e');
      return Failure(
        AuthException(message: 'google-failed', code: 'google-failed'),
      );
    }
  }

  @override
  Future<Result<void>> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = fa.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await FirebaseService.auth.signInWithCredential(
        oauthCredential,
      );
      final appleDisplayName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((p) => p != null && p.isNotEmpty).join(' ');
      await _ensureUserDocument(
        userCredential.user!,
        fallbackDisplayName: appleDisplayName.isNotEmpty
            ? appleDisplayName
            : null,
      );
      return const Success(null);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // User cancelled — not an error
        return const Success(null);
      }
      return Failure(
        AuthException(
          message: _getAppleErrorCode(e.code),
          code: _getAppleErrorCode(e.code),
        ),
      );
    } on fa.FirebaseAuthException catch (e) {
      return Failure(
        AuthException(message: _getAuthErrorMessage(e.code), code: e.code),
      );
    } on PlatformException catch (e) {
      debugPrint(
        '[Auth] signInWithApple PlatformException: ${e.code} — ${e.message}',
      );
      return Failure(
        AuthException(message: 'apple-failed', code: 'apple-failed'),
      );
    } catch (e) {
      debugPrint('[Auth] signInWithApple error: $e');
      return Failure(
        AuthException(message: 'apple-failed', code: 'apple-failed'),
      );
    }
  }

  /// Creates a Firestore user document on first OAuth sign-in.
  /// If the document already exists the method is a no-op.
  Future<void> _ensureUserDocument(
    fa.User firebaseUser, {
    String? fallbackDisplayName,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (doc.exists) return;
    final displayName =
        firebaseUser.displayName ??
        fallbackDisplayName ??
        firebaseUser.email?.split('@').first ??
        'Dreamer';
    final user = model.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      aiEnabled: true,
      timezone: 'UTC',
      notificationsEnabled: true,
      notificationTime: '08:00',
    );
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  bool _isValidNotificationTime(String value) {
    final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return timeRegex.hasMatch(value);
  }

  /// Maps Apple authorization error codes to stable semantic codes.
  String _getAppleErrorCode(AuthorizationErrorCode code) {
    return switch (code) {
      AuthorizationErrorCode.notHandled => 'apple-not-supported',
      AuthorizationErrorCode.notInteractive => 'apple-not-interactive',
      _ => 'apple-failed',
    };
  }

  /// Maps Google Sign-In PlatformException to a stable semantic code.
  String _getGooglePlatformErrorCode(PlatformException e) {
    final msg = e.message ?? '';
    final match = RegExp(r'ApiException:\s*(\d+)').firstMatch(msg);
    final apiCode = match != null ? int.tryParse(match.group(1) ?? '') : null;
    debugPrint(
      '[Auth] Google PlatformException: code=${e.code} apiCode=$apiCode msg=$msg',
    );
    return switch (apiCode) {
      7 => 'network-request-failed',
      _ => 'google-failed',
    };
  }

  /// Normalizes Firebase Auth sign-in errors into stable semantic codes.
  ///
  /// Newer Firebase SDKs can collapse both missing-user and wrong-password into
  /// `invalid-credential`, so we inspect the backend message to recover intent
  /// when possible.
  String _normalizeSignInErrorCode(fa.FirebaseAuthException e) {
    if (e.code != 'invalid-credential') {
      return e.code;
    }

    final message = (e.message ?? '').toLowerCase();

    if (message.contains('no user record') ||
        message.contains('user not found') ||
        message.contains('email address is not found') ||
        message.contains('there is no user')) {
      return 'user-not-found';
    }

    if (message.contains('wrong password') ||
        message.contains('invalid login credentials') ||
        message.contains('invalid_login_credentials') ||
        message.contains('password is invalid') ||
        message.contains('credential is incorrect')) {
      return 'wrong-password';
    }

    debugPrint(
      '[Auth] signIn received ambiguous invalid-credential: '
      'code=${e.code} message=${e.message}',
    );
    return 'invalid-credential';
  }

  /// Resolves ambiguous `invalid-credential` into a more specific sign-in code.
  Future<String> _resolveInvalidCredentialCode({required String email}) async {
    try {
      final methods = await FirebaseService.auth.fetchSignInMethodsForEmail(
        email,
      );

      if (methods.isEmpty) {
        return 'user-not-found';
      }

      if (methods.contains('password')) {
        return 'wrong-password';
      }

      return 'operation-not-allowed';
    } on fa.FirebaseAuthException catch (e) {
      debugPrint(
        '[Auth] resolve invalid-credential failed with FirebaseAuthException: '
        'code=${e.code} message=${e.message}',
      );
      return 'invalid-credential';
    } catch (e) {
      debugPrint('[Auth] resolve invalid-credential failed: $e');
      return 'invalid-credential';
    }
  }

  /// Helper to get user-friendly error message from Firebase error code
  String _getAuthErrorMessage(String code) {
    return switch (code) {
      'weak-password' => 'The password provided is too weak.',
      'email-already-in-use' => 'The account already exists for that email.',
      'invalid-email' => 'The email address is badly formatted.',
      'operation-not-allowed' =>
        'Signing up with email/password is not enabled.',
      'user-disabled' =>
        'The user account has been disabled by an administrator.',
      'user-not-found' =>
        'There is no user account associated with this email.',
      'wrong-password' => 'The password is invalid for the given email.',
      'invalid-credential' =>
        'The provided login credentials are invalid. Please try again.',
      'too-many-requests' =>
        'Too many failed login attempts. Please try again later.',
      'network-request-failed' =>
        'Network error. Please check your internet connection.',
      _ => () {
        debugPrint('[Auth] FirebaseAuthException unmapped code: $code');
        return 'auth-generic';
      }(),
    };
  }
}
