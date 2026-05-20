/// Data carried between wizard steps when creating a new dream.
/// Step 1 (form) → Step 2 (analysis) → Step 3 (saved/share).
class DreamDraft {
  const DreamDraft({
    required this.title,
    required this.text,
    required this.moodScore,
    required this.localAudioPaths,
    required this.existingAudioUrls,
    required this.removedExistingUrls,
    required this.isEditing,
    this.dreamId,
  });

  final String title;
  final String text;
  final int moodScore;

  /// Local file paths for recordings made in this session.
  final List<String> localAudioPaths;

  /// Remote URLs already stored in Firestore (edit mode).
  final List<String> existingAudioUrls;

  /// Remote URLs removed by the user (edit mode).
  final List<String> removedExistingUrls;

  final bool isEditing;

  /// Firestore document ID — only set in edit mode.
  final String? dreamId;
}
