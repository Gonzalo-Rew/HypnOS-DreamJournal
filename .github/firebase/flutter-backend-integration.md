# Firebase Backend Integration for Flutter

**Proyecto:** Hypnos Dream Journal  
**Fase:** 2 - Flutter Backend Integration Guide  
**Fecha:** 2026-04-30

---

## Objetivo

Proporcionar guía de implementación de servicios backend en Flutter que integren con las reglas de seguridad de Firebase (Auth, Firestore, Storage).

---

## 1. Project Structure

```
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── firebase/
│   │   └── firebase_config.dart
│   └── usecase/
│       └── usecase.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── user_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_up_usecase.dart
│   │   │       ├── sign_in_usecase.dart
│   │   │       ├── sign_out_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── login_page.dart
│   │           ├── signup_page.dart
│   │           └── profile_page.dart
│   │
│   ├── dreams/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── dream_remote_datasource.dart
│   │   │   │   └── dream_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── dream_model.dart
│   │   │   └── repositories/
│   │   │       └── dream_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── dream_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── dream_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_dream_usecase.dart
│   │   │       ├── get_dreams_usecase.dart
│   │   │       ├── update_dream_usecase.dart
│   │   │       └── delete_dream_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── dream_bloc.dart
│   │       │   ├── dream_event.dart
│   │       │   └── dream_state.dart
│   │       └── pages/
│   │           ├── dreams_list_page.dart
│   │           ├── dream_detail_page.dart
│   │           └── create_dream_page.dart
│   │
│   └── storage/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── audio_remote_datasource.dart
│       │   ├── models/
│       │   │   └── audio_model.dart
│       │   └── repositories/
│       │       └── audio_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── audio_entity.dart
│       │   ├── repositories/
│       │   │   └── audio_repository.dart
│       │   └── usecases/
│       │       ├── upload_audio_usecase.dart
│       │       ├── download_audio_usecase.dart
│       │       └── delete_audio_usecase.dart
│       └── presentation/
│           └── widgets/
│               └── audio_player_widget.dart
```

---

## 2. Firebase Initialization

### 2.1 Firebase Config
```dart
// lib/core/firebase/firebase_config.dart

import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
```

### 2.2 Main Entry Point
```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'core/firebase/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const MyApp());
}
```

---

## 3. Error Handling

### 3.1 Custom Exceptions
```dart
// lib/core/errors/exceptions.dart

abstract class MyException implements Exception {
  final String message;
  MyException({required this.message});
}

class AuthException extends MyException {
  AuthException({required String message}) : super(message: message);
}

class FirestoreException extends MyException {
  FirestoreException({required String message}) : super(message: message);
}

class StorageException extends MyException {
  StorageException({required String message}) : super(message: message);
}

class NetworkException extends MyException {
  NetworkException({required String message}) : super(message: message);
}
```

### 3.2 Failure Model
```dart
// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  Failure({required this.message});
}

class AuthFailure extends Failure {
  AuthFailure({required String message}) : super(message: message);
}

class FirestoreFailure extends Failure {
  FirestoreFailure({required String message}) : super(message: message);
}

class StorageFailure extends Failure {
  StorageFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure({required String message}) : super(message: message);
}
```

---

## 4. Authentication Feature

### 4.1 User Model
```dart
// lib/features/auth/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String uid,
    required String displayName,
    required String email,
    required DateTime createdAt,
    required bool aiEnabled,
    required String timezone,
  }) : super(
    uid: uid,
    displayName: displayName,
    email: email,
    createdAt: createdAt,
    aiEnabled: aiEnabled,
    timezone: timezone,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      aiEnabled: json['aiEnabled'] ?? false,
      timezone: json['timezone'] ?? 'UTC',
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      createdAt: entity.createdAt,
      aiEnabled: entity.aiEnabled,
      timezone: entity.timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'aiEnabled': aiEnabled,
      'timezone': timezone,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'displayName': displayName,
      'aiEnabled': aiEnabled,
      'timezone': timezone,
    };
  }
}
```

### 4.2 Auth Remote DataSource
```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Future<void> sendPasswordReset({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar displayName en Auth
      await userCredential.user?.updateDisplayName(displayName);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      throw AuthException(message: 'Signup failed: $e');
    }
  }

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      throw AuthException(message: 'Sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: 'Sign out failed: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return firebaseAuth.currentUser;
    } catch (e) {
      throw AuthException(message: 'Get current user failed: $e');
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      throw AuthException(message: 'Password reset failed: $e');
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed: $errorCode';
    }
  }
}
```

### 4.3 User Remote DataSource
```dart
// lib/features/auth/data/datasources/user_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class UserRemoteDataSource {
  Future<void> createUserProfile({
    required String uid,
    required UserModel user,
  });

  Future<UserModel?> getUserProfile({required String uid});

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createUserProfile({
    required String uid,
    required UserModel user,
  }) async {
    try {
      await firestore.collection('users').doc(uid).set(user.toJson());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to create user profile: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Create user profile failed: $e',
      );
    }
  }

  @override
  Future<UserModel?> getUserProfile({required String uid}) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromJson({
        'uid': uid,
        ...doc.data() ?? {},
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to get user profile: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Get user profile failed: $e',
      );
    }
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore.collection('users').doc(uid).update(data);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update user profile: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Update user profile failed: $e',
      );
    }
  }
}
```

---

## 5. Dreams Feature

### 5.1 Dream Model
```dart
// lib/features/dreams/data/models/dream_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dream_entity.dart';

class DreamModel extends DreamEntity {
  DreamModel({
    required String id,
    required String title,
    required String text,
    required DateTime dreamDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    required double? moodScore,
    required List<String> tags,
    required bool hasAudio,
    required String? audioPath,
    required String? transcription,
    required String? aiSummary,
  }) : super(
    id: id,
    title: title,
    text: text,
    dreamDate: dreamDate,
    createdAt: createdAt,
    updatedAt: updatedAt,
    moodScore: moodScore,
    tags: tags,
    hasAudio: hasAudio,
    audioPath: audioPath,
    transcription: transcription,
    aiSummary: aiSummary,
  );

  factory DreamModel.fromJson(Map<String, dynamic> json, String docId) {
    return DreamModel(
      id: docId,
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      dreamDate: (json['dreamDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      moodScore: json['moodScore']?.toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      hasAudio: json['hasAudio'] ?? false,
      audioPath: json['audioPath'],
      transcription: json['transcription'],
      aiSummary: json['aiSummary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'dreamDate': Timestamp.fromDate(dreamDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'moodScore': moodScore,
      'tags': tags,
      'hasAudio': hasAudio,
      'audioPath': audioPath,
      'transcription': transcription,
      'aiSummary': aiSummary,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'text': text,
      'dreamDate': Timestamp.fromDate(dreamDate),
      'updatedAt': FieldValue.serverTimestamp(),
      'moodScore': moodScore,
      'tags': tags,
      'hasAudio': hasAudio,
      'audioPath': audioPath,
      'transcription': transcription,
      'aiSummary': aiSummary,
    };
  }
}
```

### 5.2 Dream Remote DataSource
```dart
// lib/features/dreams/data/datasources/dream_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dream_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class DreamRemoteDataSource {
  Future<String> createDream({
    required String uid,
    required DreamModel dream,
  });

  Future<List<DreamModel>> getDreams({required String uid});

  Future<DreamModel?> getDreamById({
    required String uid,
    required String dreamId,
  });

  Future<void> updateDream({
    required String uid,
    required String dreamId,
    required DreamModel dream,
  });

  Future<void> deleteDream({
    required String uid,
    required String dreamId,
  });
}

class DreamRemoteDataSourceImpl implements DreamRemoteDataSource {
  final FirebaseFirestore firestore;

  DreamRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> createDream({
    required String uid,
    required DreamModel dream,
  }) async {
    try {
      final docRef = await firestore
          .collection('users')
          .doc(uid)
          .collection('dreams')
          .add(dream.toJson());

      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to create dream: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(message: 'Create dream failed: $e');
    }
  }

  @override
  Future<List<DreamModel>> getDreams({required String uid}) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('dreams')
          .orderBy('dreamDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DreamModel.fromJson(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch dreams: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(message: 'Get dreams failed: $e');
    }
  }

  @override
  Future<DreamModel?> getDreamById({
    required String uid,
    required String dreamId,
  }) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('dreams')
          .doc(dreamId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return DreamModel.fromJson(doc.data() ?? {}, doc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to get dream: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(message: 'Get dream failed: $e');
    }
  }

  @override
  Future<void> updateDream({
    required String uid,
    required String dreamId,
    required DreamModel dream,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('dreams')
          .doc(dreamId)
          .update(dream.toUpdateJson());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update dream: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(message: 'Update dream failed: $e');
    }
  }

  @override
  Future<void> deleteDream({
    required String uid,
    required String dreamId,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('dreams')
          .doc(dreamId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to delete dream: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(message: 'Delete dream failed: $e');
    }
  }
}
```

---

## 6. Storage Feature (Audio)

### 6.1 Audio Remote DataSource
```dart
// lib/features/storage/data/datasources/audio_remote_datasource.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AudioRemoteDataSource {
  Future<String> uploadAudio({
    required String uid,
    required String dreamId,
    required File audioFile,
  });

  Future<String> downloadAudio({
    required String uid,
    required String dreamId,
  });

  Future<void> deleteAudio({
    required String uid,
    required String dreamId,
  });
}

class AudioRemoteDataSourceImpl implements AudioRemoteDataSource {
  final FirebaseStorage firebaseStorage;

  AudioRemoteDataSourceImpl({required this.firebaseStorage});

  @override
  Future<String> uploadAudio({
    required String uid,
    required String dreamId,
    required File audioFile,
  }) async {
    try {
      final ref = firebaseStorage.ref().child(
        'users/$uid/dreams/$dreamId/audio.m4a',
      );

      final uploadTask = ref.putFile(audioFile);

      await uploadTask.whenComplete(() {});

      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to upload audio: ${e.message}',
      );
    } catch (e) {
      throw StorageException(message: 'Upload audio failed: $e');
    }
  }

  @override
  Future<String> downloadAudio({
    required String uid,
    required String dreamId,
  }) async {
    try {
      final ref = firebaseStorage.ref().child(
        'users/$uid/dreams/$dreamId/audio.m4a',
      );

      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to get audio URL: ${e.message}',
      );
    } catch (e) {
      throw StorageException(message: 'Download audio failed: $e');
    }
  }

  @override
  Future<void> deleteAudio({
    required String uid,
    required String dreamId,
  }) async {
    try {
      final ref = firebaseStorage.ref().child(
        'users/$uid/dreams/$dreamId/audio.m4a',
      );

      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to delete audio: ${e.message}',
      );
    } catch (e) {
      throw StorageException(message: 'Delete audio failed: $e');
    }
  }
}
```

---

## 7. Best Practices

### 7.1 Security
- ✅ **Never expose API keys in code** - Use `firebase_options.dart`
- ✅ **Validate all user input** before sending to Firebase
- ✅ **Use try-catch** para manejar excepciones de Firebase
- ✅ **Implement rate limiting** on sensitive operations
- ✅ **Enable SSL pinning** en producción (si es necesario)

### 7.2 Performance
- ✅ **Implement local caching** (Hive/shared_preferences)
- ✅ **Paginate queries** para grandes datasets
- ✅ **Use indexes** en Firestore para queries complejas
- ✅ **Cache authentication state** en la app
- ✅ **Lazy load** imágenes y audios

### 7.3 User Experience
- ✅ **Show loading states** durante operaciones async
- ✅ **Handle errors gracefully** con mensajes claros
- ✅ **Implement offline support** con caché local
- ✅ **Retry failed operations** automáticamente

---

## 8. Testing

### 8.1 Unit Testing
```dart
// test/features/auth/sign_up_test.dart

void main() {
  group('SignUp UseCase', () {
    test('should return UserEntity on successful signup', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'Test123456';
      const displayName = 'Test User';

      // Act
      final result = await signUpUseCase(
        SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );

      // Assert
      expect(result, isA<UserEntity>());
      expect(result.email, equals(email));
    });
  });
}
```

---

## 9. References

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd)
- [Firebase Best Practices](https://firebase.google.com/docs/database/usage/best-practices)

---

**Última actualización:** 2026-04-30  
**Versión:** 1.0  
**Responsable:** Firebase Backend Security Agent
