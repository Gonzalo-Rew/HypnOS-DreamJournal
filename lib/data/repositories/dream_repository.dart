import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';

/// Repository for dream operations
abstract class DreamRepository {
  /// Create a new dream entry
  Future<Result<Dream>> createDream({
    required String userId,
    required String title,
    required String text,
    required DateTime dreamDate,
    int? moodScore,
    List<String>? tags,
    String? contextNotes,
    String? aiCategory,
    List<String> audioPaths = const [],
    String? transcription,
    String? aiSummary,
  });

  /// Get all dreams for a user
  Future<Result<List<Dream>>> getDreamsByUser({
    required String userId,
    int limit = 50,
  });

  /// Get a single dream by ID
  Future<Result<Dream>> getDreamById({
    required String userId,
    required String dreamId,
  });

  /// Update a dream
  Future<Result<void>> updateDream({
    required String userId,
    required String dreamId,
    required Map<String, dynamic> data,
  });

  /// Delete a dream
  Future<Result<void>> deleteDream({
    required String userId,
    required String dreamId,
  });

  /// Listen to dreams for a user (real-time updates)
  Stream<List<Dream>> streamUserDreams({
    required String userId,
    int limit = 50,
  });
}

/// Implementation of DreamRepository
class DreamRepositoryImpl implements DreamRepository {
  final FirebaseFirestore _firestore;

  DreamRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore;

  @override
  Future<Result<Dream>> createDream({
    required String userId,
    required String title,
    required String text,
    required DateTime dreamDate,
    int? moodScore,
    List<String>? tags,
    String? contextNotes,
    String? aiCategory,
    List<String> audioPaths = const [],
    String? transcription,
    String? aiSummary,
  }) async {
    try {
      _requireAuthenticatedUser(expectedUserId: userId);

      if (title.trim().isEmpty) {
        throw ValidationException(
          message: 'Dream title cannot be empty',
          field: 'title',
        );
      }

      if (text.trim().isEmpty && audioPaths.isEmpty) {
        throw ValidationException(
          message: 'Dream must include text or audio',
          field: 'text',
        );
      }

      _validateMoodScore(moodScore);

      final now = DateTime.now();
      final dream = Dream(
        id: '',
        userId: userId,
        title: title.trim(),
        text: text.trim(),
        dreamDate: dreamDate,
        createdAt: now,
        updatedAt: now,
        moodScore: moodScore,
        tags: tags ?? const [],
        contextNotes: contextNotes,
        aiCategory: aiCategory,
        audioPaths: audioPaths,
        transcription: transcription,
        aiSummary: aiSummary,
      );

      final docRef = await _dreamsCollection(userId).add(dream.toFirestore());

      return Success(dream.copyWith(id: docRef.id));
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to create dream: $e'));
    }
  }

  @override
  Future<Result<List<Dream>>> getDreamsByUser({
    required String userId,
    int limit = 50,
  }) async {
    try {
      _requireAuthenticatedUser(expectedUserId: userId);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dreams')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final dreams = snapshot.docs
          .map((doc) => Dream.fromFirestore(doc.data(), doc.id, userId))
          .toList();

      return Success(dreams);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to fetch dreams: $e'));
    }
  }

  @override
  Future<Result<Dream>> getDreamById({
    required String userId,
    required String dreamId,
  }) async {
    try {
      _requireAuthenticatedUser(expectedUserId: userId);

      final doc = await _dreamDocument(userId, dreamId).get();

      if (!doc.exists) {
        throw FirestoreException(message: 'Dream not found');
      }

      return Success(Dream.fromFirestore(doc.data()!, doc.id, userId));
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to fetch dream: $e'));
    }
  }

  @override
  Future<Result<void>> updateDream({
    required String userId,
    required String dreamId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _requireAuthenticatedUser(expectedUserId: userId);

      if (data.containsKey('moodScore')) {
        _validateMoodScore(data['moodScore'] as int?);
      }

      data.remove('createdAt');
      data['updatedAt'] = DateTime.now();
      await _dreamDocument(userId, dreamId).update(data);

      // Public projection sync should never block the private dream update.
      try {
        await _syncPublicDreamProjection(userId: userId, dreamId: dreamId);
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          developer.log(
            'Skipping public dream projection sync due to permission-denied: ${e.message}',
            name: 'DreamRepository',
          );
        } else {
          rethrow;
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to update dream: $e'));
    }
  }

  @override
  Future<Result<void>> deleteDream({
    required String userId,
    required String dreamId,
  }) async {
    try {
      _requireAuthenticatedUser(expectedUserId: userId);
      await _dreamDocument(userId, dreamId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to delete dream: $e'));
    }
  }

  @override
  Stream<List<Dream>> streamUserDreams({
    required String userId,
    int limit = 50,
  }) {
    _requireAuthenticatedUser(expectedUserId: userId);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('dreams')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Dream.fromFirestore(doc.data(), doc.id, userId))
              .toList(),
        )
        .handleError(
          (e) =>
              throw FirestoreException(message: 'Failed to stream dreams: $e'),
        );
  }

  CollectionReference<Map<String, dynamic>> _dreamsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('dreams');
  }

  DocumentReference<Map<String, dynamic>> _dreamDocument(
    String userId,
    String dreamId,
  ) {
    return _dreamsCollection(userId).doc(dreamId);
  }

  void _requireAuthenticatedUser({required String expectedUserId}) {
    final currentUid = FirebaseService.getCurrentUserId();
    if (currentUid == null) {
      throw AuthException(message: 'Authenticated user is required');
    }

    if (currentUid != expectedUserId) {
      throw AuthException(message: 'User can only access their own dreams');
    }
  }

  void _validateMoodScore(int? moodScore) {
    if (moodScore == null) {
      return;
    }

    if (moodScore < 1 || moodScore > 5) {
      throw ValidationException(
        message: 'moodScore must be between 1 and 5',
        field: 'moodScore',
      );
    }
  }

  Future<void> _syncPublicDreamProjection({
    required String userId,
    required String dreamId,
  }) async {
    final dreamSnap = await _dreamDocument(userId, dreamId).get();
    if (!dreamSnap.exists) return;

    final dreamData = dreamSnap.data() ?? {};
    final isPublished = dreamData['isPublished'] as bool? ?? false;
    final publicDreamRef = _firestore.collection('publicDreams').doc(dreamId);

    if (!isPublished) {
      final publicSnap = await publicDreamRef.get();
      if (!publicSnap.exists) {
        return;
      }

      final publicOwner = publicSnap.data()?['userId'] as String?;
      if (publicOwner != userId) {
        return;
      }

      await publicDreamRef.delete();
      return;
    }

    final publicSnap = await publicDreamRef.get();
    final publicData = publicSnap.data() ?? {};

    await publicDreamRef.set({
      ...dreamData,
      'userId': userId,
      'isPublished': true,
      'visibility': dreamData['visibility'] as String? ?? 'followers',
      'publishedAt': publicData['publishedAt'] ?? FieldValue.serverTimestamp(),
      'likesCount': publicData['likesCount'] as int? ?? 0,
      'commentsCount': publicData['commentsCount'] as int? ?? 0,
    }, SetOptions(merge: true));
  }
}
