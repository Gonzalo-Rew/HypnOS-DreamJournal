/// User profile stored in users/{uid}.
class User {
  static const Object _sentinel = Object();

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
  final bool hasTutorialSeen;
  final DateTime? termsAcceptedAt;
  final DateTime? privacyAcceptedAt;
  final String? termsVersion;
  final String? privacyVersion;

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
    this.hasTutorialSeen = false,
    this.termsAcceptedAt,
    this.privacyAcceptedAt,
    this.termsVersion,
    this.privacyVersion,
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
      hasTutorialSeen: data['hasTutorialSeen'] as bool? ?? false,
      termsAcceptedAt: (data['termsAcceptedAt'] as dynamic)?.toDate(),
      privacyAcceptedAt: (data['privacyAcceptedAt'] as dynamic)?.toDate(),
      termsVersion: data['termsVersion'] as String?,
      privacyVersion: data['privacyVersion'] as String?,
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
      'hasTutorialSeen': hasTutorialSeen,
      if (termsAcceptedAt != null) 'termsAcceptedAt': termsAcceptedAt,
      if (privacyAcceptedAt != null) 'privacyAcceptedAt': privacyAcceptedAt,
      if (termsVersion != null) 'termsVersion': termsVersion,
      if (privacyVersion != null) 'privacyVersion': privacyVersion,
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
    Object? photoUrl = _sentinel,
    bool? notificationsEnabled,
    String? notificationTime,
    int? followersCount,
    int? followingCount,
    String? dreamVisibility,
    bool? notifyFollowRequests,
    bool? notifyNewFollowers,
    bool? notifyFollowingDreams,
    String? fcmToken,
    bool? hasTutorialSeen,
    DateTime? termsAcceptedAt,
    DateTime? privacyAcceptedAt,
    String? termsVersion,
    String? privacyVersion,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      timezone: timezone ?? this.timezone,
      photoUrl: identical(photoUrl, _sentinel) ? this.photoUrl : photoUrl as String?,
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
      hasTutorialSeen: hasTutorialSeen ?? this.hasTutorialSeen,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      privacyAcceptedAt: privacyAcceptedAt ?? this.privacyAcceptedAt,
      termsVersion: termsVersion ?? this.termsVersion,
      privacyVersion: privacyVersion ?? this.privacyVersion,
    );
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, displayName: $displayName)';
}
