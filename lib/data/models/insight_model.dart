/// Insight model representing patterns and analytics derived from dreams.
class Insight {
  /// Unique identifier for the insight
  final String id;

  /// User ID who owns this insight
  final String userId;

  /// Type of insight (recurring_emotion, pattern_detection, trend_analysis)
  final InsightType type;

  /// Title of the insight
  final String title;

  /// Detailed description
  final String description;

  /// Associated data/metrics
  final Map<String, dynamic> metrics;

  /// Time period covered (start date)
  final DateTime periodStart;

  /// Time period covered (end date)
  final DateTime periodEnd;

  /// Confidence score (0.0 - 1.0)
  final double confidenceScore;

  /// List of related dream IDs
  final List<String> relatedDreamIds;

  /// Actionable recommendations
  final List<String> recommendations;

  /// Creation timestamp
  final DateTime createdAt;

  /// Whether this insight has been read by the user
  final bool isRead;

  Insight({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.metrics,
    required this.periodStart,
    required this.periodEnd,
    required this.confidenceScore,
    required this.relatedDreamIds,
    required this.recommendations,
    required this.createdAt,
    required this.isRead,
  });

  /// Create an Insight from Firestore document
  factory Insight.fromFirestore(Map<String, dynamic> data, String id) {
    return Insight(
      id: id,
      userId: data['userId'] as String,
      type: InsightType.fromString(
        data['type'] as String? ?? 'pattern_detection',
      ),
      title: data['title'] as String,
      description: data['description'] as String,
      metrics: Map<String, dynamic>.from(data['metrics'] as Map? ?? {}),
      periodStart: (data['periodStart'] as dynamic)?.toDate() ?? DateTime.now(),
      periodEnd: (data['periodEnd'] as dynamic)?.toDate() ?? DateTime.now(),
      confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 0.5,
      relatedDreamIds: List<String>.from(
        data['relatedDreamIds'] as List? ?? [],
      ),
      recommendations: List<String>.from(
        data['recommendations'] as List? ?? [],
      ),
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  /// Convert Insight to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString(),
      'title': title,
      'description': description,
      'metrics': metrics,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'confidenceScore': confidenceScore,
      'relatedDreamIds': relatedDreamIds,
      'recommendations': recommendations,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  /// Create a copy of Insight with modified fields
  Insight copyWith({
    String? id,
    String? userId,
    InsightType? type,
    String? title,
    String? description,
    Map<String, dynamic>? metrics,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? confidenceScore,
    List<String>? relatedDreamIds,
    List<String>? recommendations,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Insight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      metrics: metrics ?? this.metrics,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      relatedDreamIds: relatedDreamIds ?? this.relatedDreamIds,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() => 'Insight(id: $id, userId: $userId, type: $type)';
}

/// Enum for different types of insights
enum InsightType {
  recurringEmotion('recurring_emotion'),
  patternDetection('pattern_detection'),
  trendAnalysis('trend_analysis'),
  correlationAnalysis('correlation_analysis');

  final String value;

  const InsightType(this.value);

  /// Create InsightType from string
  static InsightType fromString(String value) {
    return InsightType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InsightType.patternDetection,
    );
  }

  @override
  String toString() => value;
}
