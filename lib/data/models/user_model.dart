/// User profile stored in users/{uid}.
class User {
  final String id;
  final String displayName;
  final String email;
  final DateTime createdAt;
  final bool aiEnabled;
  final String timezone;
  final String? photoUrl;
  final bool notificationsEnabled;
  final String notificationTime;

  User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.createdAt,
    required this.aiEnabled,
    required this.timezone,
    this.photoUrl,
    required this.notificationsEnabled,
    required this.notificationTime,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      aiEnabled: data['aiEnabled'] as bool? ?? true,
      timezone: data['timezone'] as String? ?? 'UTC',
      photoUrl: data['photoUrl'] as String?,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      notificationTime: data['notificationTime'] as String? ?? '08:00',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'createdAt': createdAt,
      'aiEnabled': aiEnabled,
      'timezone': timezone,
      'photoUrl': photoUrl,
      'notificationsEnabled': notificationsEnabled,
      'notificationTime': notificationTime,
    };
  }

  User copyWith({
    String? id,
    String? displayName,
    String? email,
    DateTime? createdAt,
    bool? aiEnabled,
    String? timezone,
    String? photoUrl,
    bool? notificationsEnabled,
    String? notificationTime,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      timezone: timezone ?? this.timezone,
      photoUrl: photoUrl ?? this.photoUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, displayName: $displayName)';
}
