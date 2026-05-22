/// User profile stored in users/{uid}.
class User {
  final String id;
  final String displayName;
  final String? username;
  final String email;
  final DateTime createdAt;
  final bool aiEnabled;
  final String timezone;
  final String? photoUrl;
  final bool notificationsEnabled;
  final String notificationTime;
  final int followersCount;
  final int followingCount;
  final String dreamVisibility; // 'public' | 'followers' | 'private'
  final bool notifyFollowRequests;
  final bool notifyNewFollowers;
  final bool notifyFollowingDreams;
  final String? fcmToken;

  User({
    required this.id,
    required this.displayName,
    this.username,
    required this.email,
    required this.createdAt,
    required this.aiEnabled,
    required this.timezone,
    this.photoUrl,
    required this.notificationsEnabled,
    required this.notificationTime,
    this.followersCount = 0,
    this.followingCount = 0,
    this.dreamVisibility = 'followers',
    this.notifyFollowRequests = true,
    this.notifyNewFollowers = true,
    this.notifyFollowingDreams = true,
    this.fcmToken,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      displayName: data['displayName'] as String? ?? '',
      username: data['username'] as String?,
      email: data['email'] as String? ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      aiEnabled: data['aiEnabled'] as bool? ?? true,
      timezone: data['timezone'] as String? ?? 'UTC',
      photoUrl: data['photoUrl'] as String?,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      notificationTime: data['notificationTime'] as String? ?? '08:00',
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      dreamVisibility: switch (data['dreamVisibility'] as String?) {
        'public' => 'public',
        'followers' => 'followers',
        _ => 'followers',
      },
      notifyFollowRequests: data['notifyFollowRequests'] as bool? ?? true,
      notifyNewFollowers: data['notifyNewFollowers'] as bool? ?? true,
      notifyFollowingDreams: data['notifyFollowingDreams'] as bool? ?? true,
      fcmToken: data['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'username': username,
      'email': email,
      'createdAt': createdAt,
      'aiEnabled': aiEnabled,
      'timezone': timezone,
      'photoUrl': photoUrl,
      'notificationsEnabled': notificationsEnabled,
      'notificationTime': notificationTime,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'dreamVisibility': dreamVisibility,
      'notifyFollowRequests': notifyFollowRequests,
      'notifyNewFollowers': notifyNewFollowers,
      'notifyFollowingDreams': notifyFollowingDreams,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  User copyWith({
    String? id,
    String? displayName,
    String? username,
    String? email,
    DateTime? createdAt,
    bool? aiEnabled,
    String? timezone,
    String? photoUrl,
    bool? notificationsEnabled,
    String? notificationTime,
    int? followersCount,
    int? followingCount,
    String? dreamVisibility,
    bool? notifyFollowRequests,
    bool? notifyNewFollowers,
    bool? notifyFollowingDreams,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      timezone: timezone ?? this.timezone,
      photoUrl: photoUrl ?? this.photoUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      dreamVisibility: dreamVisibility ?? this.dreamVisibility,
      notifyFollowRequests: notifyFollowRequests ?? this.notifyFollowRequests,
      notifyNewFollowers: notifyNewFollowers ?? this.notifyNewFollowers,
      notifyFollowingDreams:
          notifyFollowingDreams ?? this.notifyFollowingDreams,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, displayName: $displayName)';
}
