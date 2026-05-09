/// Dream document stored under users/{uid}/dreams/{dreamId}.
class Dream {
  final String id;
  final String userId;
  final String title;
  final String text;
  final DateTime dreamDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? moodScore;
  final List<String> tags;
  final String? contextNotes;
  final String? aiCategory;
  final List<String> audioPaths;
  final String? transcription;
  final String? aiSummary;

  bool get hasAudio => audioPaths.isNotEmpty;

  Dream({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.dreamDate,
    required this.createdAt,
    required this.updatedAt,
    this.moodScore,
    required this.tags,
    this.contextNotes,
    this.aiCategory,
    List<String>? audioPaths,
    this.transcription,
    this.aiSummary,
  }) : audioPaths = audioPaths ?? const [];

  factory Dream.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String userId,
  ) {
    return Dream(
      id: id,
      userId: userId,
      title: data['title'] as String? ?? '',
      text: data['text'] as String? ?? '',
      dreamDate: (data['dreamDate'] as dynamic)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      moodScore: data['moodScore'] as int?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      contextNotes: data['contextNotes'] as String?,
      aiCategory: data['aiCategory'] as String?,
      audioPaths: _readAudioPaths(data),
      transcription: data['transcription'] as String?,
      aiSummary: data['aiSummary'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'text': text,
      'dreamDate': dreamDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'moodScore': moodScore,
      'tags': tags,
      'contextNotes': contextNotes,
      'aiCategory': aiCategory,
      'hasAudio': hasAudio,
      'audioPaths': audioPaths,
      'transcription': transcription,
      'aiSummary': aiSummary,
    };
  }

  /// Reads audioPaths from Firestore, falling back to legacy single audioPath.
  static List<String> _readAudioPaths(Map<String, dynamic> data) {
    final rawList = data['audioPaths'];
    if (rawList is List && rawList.isNotEmpty) {
      return List<String>.from(rawList);
    }
    final legacy = data['audioPath'] as String?;
    if (legacy != null && legacy.isNotEmpty) {
      return [legacy];
    }
    return const [];
  }

  Dream copyWith({
    String? id,
    String? userId,
    String? title,
    String? text,
    DateTime? dreamDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? moodScore,
    List<String>? tags,
    String? contextNotes,
    String? aiCategory,
    List<String>? audioPaths,
    String? transcription,
    String? aiSummary,
  }) {
    return Dream(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      text: text ?? this.text,
      dreamDate: dreamDate ?? this.dreamDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moodScore: moodScore ?? this.moodScore,
      tags: tags ?? this.tags,
      contextNotes: contextNotes ?? this.contextNotes,
      aiCategory: aiCategory ?? this.aiCategory,
      audioPaths: audioPaths ?? this.audioPaths,
      transcription: transcription ?? this.transcription,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }

  @override
  String toString() => 'Dream(id: $id, userId: $userId, title: $title)';
}
