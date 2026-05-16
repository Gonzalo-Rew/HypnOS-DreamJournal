import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase service initializer and configuration
class FirebaseService {
  static FirebaseAuth? _authInstance;
  static FirebaseFirestore? _firestoreInstance;
  static FirebaseStorage? _storageInstance;

  /// Initialize Firebase for the application
  /// Call this in main() before runApp()
  static Future<void> initialize({FirebaseOptions? options}) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }

      // Initialize instances
      _authInstance = FirebaseAuth.instance;
      _firestoreInstance = FirebaseFirestore.instance;
      _storageInstance = FirebaseStorage.instance;

      // Set up Firestore settings for development/testing if needed
      _firestoreInstance?.settings = const Settings(persistenceEnabled: true);
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (_authInstance == null) {
      throw Exception(
        'FirebaseAuth not initialized. Call FirebaseService.initialize() first.',
      );
    }
    return _authInstance!;
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestoreInstance == null) {
      throw Exception(
        'Firestore not initialized. Call FirebaseService.initialize() first.',
      );
    }
    return _firestoreInstance!;
  }

  /// Get Firebase Storage instance
  static FirebaseStorage get storage {
    if (_storageInstance == null) {
      throw Exception(
        'Firebase Storage not initialized. Call FirebaseService.initialize() first.',
      );
    }
    return _storageInstance!;
  }

  /// Get current user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return getCurrentUser() != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return getCurrentUser()?.uid;
  }

  /// Listen to auth state changes
  static Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }
}
