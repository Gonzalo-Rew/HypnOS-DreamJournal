import 'package:flutter_test/flutter_test.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';

void main() {
  // ── DreamComment ───────────────────────────────────────────────────────────

  group('DreamComment.fromFirestore', () {
    test('parses all fields correctly', () {
      final comment = DreamComment.fromFirestore({
        'userId': 'user-1',
        'userName': 'Morpheus',
        'userPhotoUrl': 'https://example.com/photo.jpg',
        'text': 'Great dream!',
        'createdAt': null, // null → DateTime.now() default
      }, 'comment-99');

      expect(comment.id, 'comment-99');
      expect(comment.userId, 'user-1');
      expect(comment.userName, 'Morpheus');
      expect(comment.userPhotoUrl, 'https://example.com/photo.jpg');
      expect(comment.text, 'Great dream!');
    });

    test('defaults userId to empty string when missing', () {
      final comment = DreamComment.fromFirestore({}, 'c1');
      expect(comment.userId, '');
    });

    test('defaults userName to "Usuario" when missing', () {
      final comment = DreamComment.fromFirestore({}, 'c1');
      expect(comment.userName, 'Usuario');
    });

    test('defaults userPhotoUrl to null when missing', () {
      final comment = DreamComment.fromFirestore({}, 'c1');
      expect(comment.userPhotoUrl, isNull);
    });

    test('defaults text to empty string when missing', () {
      final comment = DreamComment.fromFirestore({}, 'c1');
      expect(comment.text, '');
    });

    test('uses DateTime.now() when createdAt is null', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final comment = DreamComment.fromFirestore({'createdAt': null}, 'c1');
      expect(comment.createdAt.isAfter(before), isTrue);
    });
  });

  // ── FollowRequest ──────────────────────────────────────────────────────────

  group('FollowRequest.fromFirestore', () {
    test('parses all fields correctly', () {
      final req = FollowRequest.fromFirestore({
        'requesterId': 'req-user',
        'requesterName': 'Alice',
        'requesterPhotoUrl': 'https://example.com/alice.jpg',
        'targetId': 'target-user',
        'createdAt': null,
      }, 'req-doc-id');

      expect(req.id, 'req-doc-id');
      expect(req.requesterId, 'req-user');
      expect(req.requesterName, 'Alice');
      expect(req.requesterPhotoUrl, 'https://example.com/alice.jpg');
      expect(req.targetId, 'target-user');
    });

    test('defaults requesterId to empty string when missing', () {
      final req = FollowRequest.fromFirestore({}, 'r1');
      expect(req.requesterId, '');
    });

    test('defaults requesterName to "Usuario" when missing', () {
      final req = FollowRequest.fromFirestore({}, 'r1');
      expect(req.requesterName, 'Usuario');
    });

    test('defaults requesterPhotoUrl to null', () {
      final req = FollowRequest.fromFirestore({}, 'r1');
      expect(req.requesterPhotoUrl, isNull);
    });

    test('defaults targetId to empty string', () {
      final req = FollowRequest.fromFirestore({}, 'r1');
      expect(req.targetId, '');
    });

    test('uses DateTime.now() when createdAt is null', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final req = FollowRequest.fromFirestore({'createdAt': null}, 'r1');
      expect(req.createdAt.isAfter(before), isTrue);
    });
  });
}
