import 'package:flutter_test/flutter_test.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';

class _FakeTs {
  _FakeTs(this._dt);
  final DateTime _dt;
  DateTime toDate() => _dt;
}

void main() {
  final createdAt = DateTime(2025, 3, 15);

  Map<String, dynamic> _fullData() => {
    'displayName': 'Luna Soñadora',
    'username': 'luna_dreams',
    'email': 'luna@example.com',
    'createdAt': _FakeTs(createdAt),
    'aiEnabled': true,
    'timezone': 'Europe/Madrid',
    'photoUrl': 'https://example.com/photo.jpg',
    'notificationsEnabled': true,
    'notificationTime': '09:30',
    'followersCount': 42,
    'followingCount': 17,
    'dreamVisibility': 'followers',
    'notifyFollowRequests': true,
    'notifyNewFollowers': false,
    'notifyFollowingDreams': true,
    'fcmToken': 'token-abc-123',
  };

  // ── fromFirestore ──────────────────────────────────────────────────────────

  group('User.fromFirestore – full data', () {
    late User user;
    setUp(() => user = User.fromFirestore(_fullData(), 'user-42'));

    test('id is set from parameter', () => expect(user.id, 'user-42'));
    test('displayName', () => expect(user.displayName, 'Luna Soñadora'));
    test('username', () => expect(user.username, 'luna_dreams'));
    test('email', () => expect(user.email, 'luna@example.com'));
    test(
      'createdAt from fake timestamp',
      () => expect(user.createdAt, createdAt),
    );
    test('aiEnabled = true', () => expect(user.aiEnabled, isTrue));
    test('timezone', () => expect(user.timezone, 'Europe/Madrid'));
    test('photoUrl', () {
      expect(user.photoUrl, 'https://example.com/photo.jpg');
    });
    test(
      'notificationsEnabled',
      () => expect(user.notificationsEnabled, isTrue),
    );
    test('notificationTime', () => expect(user.notificationTime, '09:30'));
    test('followersCount = 42', () => expect(user.followersCount, 42));
    test('followingCount = 17', () => expect(user.followingCount, 17));
    test('dreamVisibility = followers', () {
      expect(user.dreamVisibility, 'followers');
    });
    test('notifyFollowRequests = true', () {
      expect(user.notifyFollowRequests, isTrue);
    });
    test('notifyNewFollowers = false', () {
      expect(user.notifyNewFollowers, isFalse);
    });
    test('notifyFollowingDreams = true', () {
      expect(user.notifyFollowingDreams, isTrue);
    });
    test('fcmToken', () => expect(user.fcmToken, 'token-abc-123'));
  });

  group('User.fromFirestore – defaults for missing fields', () {
    late User user;
    setUp(() => user = User.fromFirestore({}, 'uid'));

    test(
      'displayName defaults to empty string',
      () => expect(user.displayName, ''),
    );
    test('username defaults to null', () => expect(user.username, isNull));
    test('email defaults to empty string', () => expect(user.email, ''));
    test('aiEnabled defaults to true', () => expect(user.aiEnabled, isTrue));
    test('timezone defaults to UTC', () => expect(user.timezone, 'UTC'));
    test('photoUrl defaults to null', () => expect(user.photoUrl, isNull));
    test('notificationsEnabled defaults to true', () {
      expect(user.notificationsEnabled, isTrue);
    });
    test('notificationTime defaults to 08:00', () {
      expect(user.notificationTime, '08:00');
    });
    test('followersCount defaults to 0', () => expect(user.followersCount, 0));
    test('followingCount defaults to 0', () => expect(user.followingCount, 0));
    test('dreamVisibility defaults to public', () {
      expect(user.dreamVisibility, 'public');
    });
    test('notifyFollowRequests defaults to true', () {
      expect(user.notifyFollowRequests, isTrue);
    });
    test('notifyNewFollowers defaults to true', () {
      expect(user.notifyNewFollowers, isTrue);
    });
    test('notifyFollowingDreams defaults to true', () {
      expect(user.notifyFollowingDreams, isTrue);
    });
    test('fcmToken defaults to null', () => expect(user.fcmToken, isNull));
  });

  // ── toFirestore ────────────────────────────────────────────────────────────

  group('User.toFirestore', () {
    late Map<String, dynamic> map;
    setUp(() {
      map = User(
        id: 'u1',
        displayName: 'Test User',
        email: 'test@test.com',
        createdAt: createdAt,
        aiEnabled: false,
        timezone: 'UTC',
        notificationsEnabled: false,
        notificationTime: '10:00',
        notifyFollowingDreams: false,
        fcmToken: 'my-token',
      ).toFirestore();
    });

    test('includes displayName', () => expect(map['displayName'], 'Test User'));
    test('includes email', () => expect(map['email'], 'test@test.com'));
    test('includes aiEnabled = false', () => expect(map['aiEnabled'], isFalse));
    test('includes timezone', () => expect(map['timezone'], 'UTC'));
    test('includes notificationsEnabled', () {
      expect(map['notificationsEnabled'], isFalse);
    });
    test('includes notifyFollowingDreams = false', () {
      expect(map['notifyFollowingDreams'], isFalse);
    });
    test('includes fcmToken when present', () {
      expect(map['fcmToken'], 'my-token');
    });
  });

  group('User.toFirestore – fcmToken null is excluded', () {
    test('fcmToken key absent when null', () {
      final map = User(
        id: 'u1',
        displayName: 'A',
        email: 'a@a.com',
        createdAt: createdAt,
        aiEnabled: true,
        timezone: 'UTC',
        notificationsEnabled: true,
        notificationTime: '08:00',
      ).toFirestore();
      expect(map.containsKey('fcmToken'), isFalse);
    });
  });

  // ── copyWith ───────────────────────────────────────────────────────────────

  group('User.copyWith', () {
    late User original;
    setUp(() {
      original = User(
        id: 'u1',
        displayName: 'Original',
        email: 'orig@test.com',
        createdAt: createdAt,
        aiEnabled: true,
        timezone: 'UTC',
        notificationsEnabled: true,
        notificationTime: '08:00',
        followersCount: 10,
        followingCount: 5,
      );
    });

    test('changing displayName keeps other fields', () {
      final copy = original.copyWith(displayName: 'New Name');
      expect(copy.displayName, 'New Name');
      expect(copy.email, 'orig@test.com');
      expect(copy.id, 'u1');
    });

    test('changing followersCount', () {
      final copy = original.copyWith(followersCount: 100);
      expect(copy.followersCount, 100);
      expect(original.followersCount, 10);
    });

    test('changing fcmToken', () {
      final copy = original.copyWith(fcmToken: 'new-token');
      expect(copy.fcmToken, 'new-token');
    });

    test('changing notifyFollowingDreams to false', () {
      final copy = original.copyWith(notifyFollowingDreams: false);
      expect(copy.notifyFollowingDreams, isFalse);
    });

    test('no-arg copyWith returns equivalent user', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.displayName, original.displayName);
    });
  });
}
