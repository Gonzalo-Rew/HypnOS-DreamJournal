import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

// ─── Comment model ────────────────────────────────────────────────────────────

class DreamComment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;

  DreamComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory DreamComment.fromFirestore(Map<String, dynamic> data, String id) {
    return DreamComment(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Usuario',
      userPhotoUrl: data['userPhotoUrl'] as String?,
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─── Abstract interface ───────────────────────────────────────────────────────

abstract class SocialRepository {
  /// Follow [targetUserId] as [currentUserId].
  Future<Result<void>> follow({
    required String currentUserId,
    required String targetUserId,
  });

  /// Unfollow [targetUserId] as [currentUserId].
  Future<Result<void>> unfollow({
    required String currentUserId,
    required String targetUserId,
  });

  /// Remove [followerUserId] from [currentUserId]'s followers list.
  Future<Result<void>> removeFollower({
    required String currentUserId,
    required String followerUserId,
  });

  /// Stream that emits true when [currentUserId] follows [targetUserId].
  Stream<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  });

  /// Like a dream in publicDreams.
  Future<Result<void>> likeDream({
    required String userId,
    required String dreamId,
  });

  /// Remove like from a dream in publicDreams.
  Future<Result<void>> unlikeDream({
    required String userId,
    required String dreamId,
  });

  /// Stream: true when [userId] has liked [dreamId].
  Stream<bool> isDreamLiked({required String userId, required String dreamId});

  /// Stream of comments for a public dream.
  Stream<List<DreamComment>> getComments(String dreamId);

  /// Add a comment on a public dream.
  Future<Result<void>> addComment({
    required String dreamId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String text,
  });

  /// Delete own comment.
  Future<Result<void>> deleteComment({
    required String dreamId,
    required String commentId,
    required String requestingUserId,
  });

  /// Publish a dream: writes to publicDreams collection.
  Future<Result<void>> publishDream({
    required String dreamId,
    required String userId,
    required Map<String, dynamic> dreamData,
  });

  /// Unpublish a dream: removes from publicDreams collection.
  Future<Result<void>> unpublishDream(String dreamId);

  /// Stream of public dreams for a given user (profile view).
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getPublicDreamsByUser(String userId);

  /// Stream of feed dreams: own published + following users' published.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getFeedDreams(
    String currentUserId,
  );

  /// Search users whose displayName starts with [query].
  Future<List<Map<String, dynamic>>> searchUsersByName(String query);

  // ── Follow Requests ────────────────────────────────────────────────────────

  /// Send a follow request from [currentUserId] to [targetUserId].
  Future<Result<void>> sendFollowRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// Cancel a pending follow request.
  Future<Result<void>> cancelFollowRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// Accept an incoming follow request.
  Future<Result<void>> acceptFollowRequest({
    required String requestId,
    required String requesterId,
    required String targetUserId,
  });

  /// Decline an incoming follow request.
  Future<Result<void>> declineFollowRequest(String requestId);

  /// Stream of pending follow requests for [userId] (incoming).
  Stream<List<FollowRequest>> getIncomingFollowRequests(String userId);

  /// Stream of the current relationship state between two users.
  /// Emits 'following', 'pending', or 'none'.
  Stream<String> getFollowState({
    required String currentUserId,
    required String targetUserId,
  });

  /// Stream of pending incoming request count (for badge).
  Stream<int> pendingFollowRequestCount(String userId);

  /// Save the FCM token for a user.
  Future<void> saveFcmToken({required String userId, required String token});
}

// ─── FollowRequest model ──────────────────────────────────────────────────────

class FollowRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String? requesterPhotoUrl;
  final String targetId;
  final DateTime createdAt;

  FollowRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    this.requesterPhotoUrl,
    required this.targetId,
    required this.createdAt,
  });

  factory FollowRequest.fromFirestore(Map<String, dynamic> data, String id) {
    return FollowRequest(
      id: id,
      requesterId: data['requesterId'] as String? ?? '',
      requesterName: data['requesterName'] as String? ?? 'Usuario',
      requesterPhotoUrl: data['requesterPhotoUrl'] as String?,
      targetId: data['targetId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class SocialRepositoryImpl implements SocialRepository {
  final FirebaseFirestore _firestore;

  SocialRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore;

  // Follow doc id: "{followerId}_{followingId}"
  String _followDocId(String followerId, String followingId) =>
      '${followerId}_$followingId';

  @override
  Future<Result<void>> follow({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final docId = _followDocId(currentUserId, targetUserId);
      // Only write the follow document. Updating the target user's counters
      // from client is blocked by Firestore rules (owner-only updates).
      await _firestore.collection('follows').doc(docId).set({
        'followerId': currentUserId,
        'followingId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> unfollow({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final docId = _followDocId(currentUserId, targetUserId);
      await _firestore.collection('follows').doc(docId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFollower({
    required String currentUserId,
    required String followerUserId,
  }) async {
    try {
      final docId = _followDocId(followerUserId, currentUserId);
      await _firestore.collection('follows').doc(docId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Stream<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) {
    final docId = _followDocId(currentUserId, targetUserId);
    return _firestore
        .collection('follows')
        .doc(docId)
        .snapshots()
        .map((snap) => snap.exists);
  }

  @override
  Future<Result<void>> likeDream({
    required String userId,
    required String dreamId,
  }) async {
    try {
      await _firestore
          .collection('publicDreams')
          .doc(dreamId)
          .collection('likes')
          .doc(userId)
          .set({'userId': userId, 'createdAt': FieldValue.serverTimestamp()});
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> unlikeDream({
    required String userId,
    required String dreamId,
  }) async {
    try {
      await _firestore
          .collection('publicDreams')
          .doc(dreamId)
          .collection('likes')
          .doc(userId)
          .delete();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Stream<bool> isDreamLiked({required String userId, required String dreamId}) {
    return _firestore
        .collection('publicDreams')
        .doc(dreamId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.exists);
  }

  @override
  Stream<List<DreamComment>> getComments(String dreamId) {
    return _firestore
        .collection('publicDreams')
        .doc(dreamId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => DreamComment.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<Result<void>> addComment({
    required String dreamId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String text,
  }) async {
    try {
      final batch = _firestore.batch();
      final commentRef = _firestore
          .collection('publicDreams')
          .doc(dreamId)
          .collection('comments')
          .doc();

      batch.set(commentRef, {
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(_firestore.collection('publicDreams').doc(dreamId), {
        'commentsCount': FieldValue.increment(1),
      });

      await batch.commit();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteComment({
    required String dreamId,
    required String commentId,
    required String requestingUserId,
  }) async {
    try {
      final batch = _firestore.batch();

      batch.delete(
        _firestore
            .collection('publicDreams')
            .doc(dreamId)
            .collection('comments')
            .doc(commentId),
      );
      batch.update(_firestore.collection('publicDreams').doc(dreamId), {
        'commentsCount': FieldValue.increment(-1),
      });

      await batch.commit();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> publishDream({
    required String dreamId,
    required String userId,
    required Map<String, dynamic> dreamData,
  }) async {
    try {
      await _firestore.collection('publicDreams').doc(dreamId).set({
        ...dreamData,
        'userId': userId,
        'isPublished': true,
        'publishedAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
      });
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> unpublishDream(String dreamId) async {
    try {
      await _firestore.collection('publicDreams').doc(dreamId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getPublicDreamsByUser(String userId) {
    return _firestore
        .collection('publicDreams')
        .where('userId', isEqualTo: userId)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getFeedDreams(
    String currentUserId,
  ) {
    // Returns the 30 most recent public dreams from all users.
    // A proper following-only feed requires Cloud Functions or client filtering.
    return _firestore
        .collection('publicDreams')
        .orderBy('publishedAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// Search users by displayName prefix (case-sensitive Firestore range query).
  @override
  Future<List<Map<String, dynamic>>> searchUsersByName(String query) async {
    if (query.trim().isEmpty) return [];
    final end = '${query.trim()}\uf8ff';
    final snap = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query.trim())
        .where('displayName', isLessThanOrEqualTo: end)
        .limit(30)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // ── Follow Requests ────────────────────────────────────────────────────────

  String _followRequestDocId(String requesterId, String targetId) =>
      '${requesterId}_$targetId';

  @override
  Future<Result<void>> sendFollowRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Read requester display name for denormalization
      final userSnap = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final userData = userSnap.data() ?? {};
      final docId = _followRequestDocId(currentUserId, targetUserId);
      await _firestore.collection('followRequests').doc(docId).set({
        'requesterId': currentUserId,
        'requesterName': userData['displayName'] ?? 'Usuario',
        'requesterPhotoUrl': userData['photoUrl'],
        'targetId': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> cancelFollowRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final docId = _followRequestDocId(currentUserId, targetUserId);
      await _firestore.collection('followRequests').doc(docId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> acceptFollowRequest({
    required String requestId,
    required String requesterId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();
      final followDocId = _followDocId(requesterId, targetUserId);

      // Create follow relationship
      batch.set(_firestore.collection('follows').doc(followDocId), {
        'followerId': requesterId,
        'followingId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Remove the request
      batch.delete(_firestore.collection('followRequests').doc(requestId));

      await batch.commit();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> declineFollowRequest(String requestId) async {
    try {
      await _firestore.collection('followRequests').doc(requestId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  Stream<List<FollowRequest>> getIncomingFollowRequests(String userId) {
    return _firestore
        .collection('followRequests')
        .where('targetId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final requests = <FollowRequest>[];

          for (final doc in snap.docs) {
            final data = doc.data();
            final status = data['status'] as String?;
            if ((status ?? 'pending') == 'pending') {
              requests.add(FollowRequest.fromFirestore(data, doc.id));
            }
          }

          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  @override
  Stream<String> getFollowState({
    required String currentUserId,
    required String targetUserId,
  }) {
    final followDocId = _followDocId(currentUserId, targetUserId);
    final requestDocId = _followRequestDocId(currentUserId, targetUserId);

    return Stream<String>.multi((controller) {
      var isFollowing = false;
      var isPending = false;

      void emitState() {
        controller.add(
          isFollowing ? 'following' : (isPending ? 'pending' : 'none'),
        );
      }

      final followSub = _firestore
          .collection('follows')
          .doc(followDocId)
          .snapshots()
          .listen((followSnap) {
            isFollowing = followSnap.exists;
            emitState();
          }, onError: controller.addError);

      final requestSub = _firestore
          .collection('followRequests')
          .doc(requestDocId)
          .snapshots()
          .listen((reqSnap) {
            final status = reqSnap.data()?['status'] as String?;
            isPending = reqSnap.exists && (status ?? 'pending') == 'pending';
            emitState();
          }, onError: controller.addError);

      controller.onCancel = () async {
        await followSub.cancel();
        await requestSub.cancel();
      };
    });
  }

  @override
  Stream<int> pendingFollowRequestCount(String userId) {
    return _firestore
        .collection('followRequests')
        .where('targetId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs.where((d) {
            final status = d.data()['status'] as String?;
            return (status ?? 'pending') == 'pending';
          }).length,
        );
  }

  @override
  Future<void> saveFcmToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      debugPrint('[FCM] Failed to save token: $e');
    }
  }
}
