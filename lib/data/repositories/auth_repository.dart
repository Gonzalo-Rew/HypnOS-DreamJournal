import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email});

  /// Get current user
  Future<Result<model.User>> getCurrentUser();

  /// Listen to auth state changes
  Stream<model.User?> authStateChanges();

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

      // Create user account
      final userCredential = await FirebaseService.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      final user = model.User(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        aiEnabled: true,
        timezone: 'UTC',
        notificationsEnabled: true,
        notificationTime: '08:00',
      );

      await _firestore.collection('users').doc(user.id).set(user.toFirestore());

      return const Success(null);
    } on fa.FirebaseAuthException catch (e) {
      return Failure(
        AuthException(message: _getAuthErrorMessage(e.code), code: e.code),
      );
    } catch (e) {
      return Failure(AuthException(message: 'Sign up failed: $e'));
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
      return Failure(
        AuthException(message: _getAuthErrorMessage(e.code), code: e.code),
      );
    } catch (e) {
      return Failure(AuthException(message: 'Sign in failed: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await FirebaseService.auth.signOut();
      return const Success(null);
    } catch (e) {
      return Failure(AuthException(message: 'Sign out failed: $e'));
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
      return Failure(AuthException(message: 'Password reset failed: $e'));
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

      // Update Firebase Auth profile
      if (displayName != null) {
        await currentUser.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await currentUser.updatePhotoURL(photoUrl);
      }

      if (notificationTime != null &&
          !_isValidNotificationTime(notificationTime)) {
        throw ValidationException(
          message: 'notificationTime must follow HH:mm format',
          field: 'notificationTime',
        );
      }

      // Update Firestore document
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (aiEnabled != null) updateData['aiEnabled'] = aiEnabled;
      if (timezone != null) updateData['timezone'] = timezone;
      if (notificationsEnabled != null) {
        updateData['notificationsEnabled'] = notificationsEnabled;
      }
      if (notificationTime != null) {
        updateData['notificationTime'] = notificationTime;
      }

      if (updateData.isEmpty) {
        return const Success(null);
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(updateData);

      return const Success(null);
    } catch (e) {
      return Failure(AuthException(message: 'Profile update failed: $e'));
    }
  }

  bool _isValidNotificationTime(String value) {
    final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return timeRegex.hasMatch(value);
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
      'too-many-requests' =>
        'Too many failed login attempts. Please try again later.',
      'network-request-failed' =>
        'Network error. Please check your internet connection.',
      _ => 'An authentication error occurred: $code',
    };
  }
}
