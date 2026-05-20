import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';

/// Analysis result returned by Gemini AI.
class DreamAnalysis {
  final String sentiment;
  final String category;
  final List<String> emotions;
  final List<String> characters;
  final List<String> places;
  final List<String> themes;
  final String psychologicalNote;
  final String summary;

  const DreamAnalysis({
    required this.sentiment,
    required this.category,
    required this.emotions,
    required this.characters,
    required this.places,
    required this.themes,
    required this.psychologicalNote,
    required this.summary,
  });

  factory DreamAnalysis.fromText(String rawText) {
    // Parse the structured plain-text response from Gemini
    String extract(String key) {
      final pattern = RegExp('$key:\\s*(.+)', caseSensitive: false);
      final match = pattern.firstMatch(rawText);
      return match?.group(1)?.trim() ?? '';
    }

    List<String> extractList(String key) {
      final raw = extract(key);
      if (raw.isEmpty) return [];
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    String extractBlock(String key) {
      final pattern = RegExp(
        '$key:\\s*([\\s\\S]+?)(?=\\n[A-Z_]+:|\$)',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(rawText);
      return match?.group(1)?.trim() ?? '';
    }

    return DreamAnalysis(
      sentiment: extract('SENTIMENT'),
      category: extract('CATEGORY'),
      emotions: extractList('EMOTIONS'),
      characters: extractList('CHARACTERS'),
      places: extractList('PLACES'),
      themes: extractList('THEMES'),
      psychologicalNote: extractBlock('PSYCHOLOGICAL_NOTE'),
      summary: extractBlock('SUMMARY'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sentiment': sentiment,
      'category': category,
      'emotions': emotions,
      'characters': characters,
      'places': places,
      'themes': themes,
      'psychologicalNote': psychologicalNote,
      'summary': summary,
    };
  }

  @override
  String toString() =>
      'DreamAnalysis(sentiment: $sentiment, category: $category, themes: $themes)';
}

/// Service for Gemini AI dream analysis — calls Firebase Cloud Functions.
/// The API key lives exclusively in Firebase Secret Manager; it never
/// reaches the client device.
class GeminiService {
  GeminiService._();

  static final GeminiService instance = GeminiService._();

  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // Always ready — no client-side initialisation needed.
  bool get isInitialized => true;

  /// Analyze a dream entry and return structured insights.
  Future<Result<DreamAnalysis>> analyzeDream({
    required String title,
    required String text,
    int? moodScore,
    String? contextNotes,
  }) async {
    if (text.trim().isEmpty) {
      return Failure(
        ValidationException(message: 'Dream text cannot be empty for analysis'),
      );
    }

    try {
      final callable = _functions.httpsCallable('analyzeDream');
      final response = await callable.call<Map<String, dynamic>>({
        'title': title,
        'text': text,
        'moodScore': moodScore,
        'contextNotes': contextNotes,
      });

      final rawText = response.data['analysisText'] as String?;
      if (rawText == null || rawText.isEmpty) {
        return Failure(
          AppException(message: 'Morfeo returned an empty response'),
        );
      }

      return Success(DreamAnalysis.fromText(rawText));
    } on FirebaseFunctionsException catch (e) {
      return Failure(AppException(message: 'Morfeo error: ${e.message}'));
    } catch (e) {
      return Failure(AppException(message: 'Failed to analyze dream: $e'));
    }
  }

  /// Transcribe audio content using Gemini multimodal via Cloud Function.
  Future<Result<String>> transcribeAudioBytes({
    required Uint8List audioBytes,
    String mimeType = 'audio/m4a',
  }) async {
    try {
      final audioBase64 = base64Encode(audioBytes);

      final callable = _functions.httpsCallable('transcribeAudio');
      final response = await callable.call<Map<String, dynamic>>({
        'audioBase64': audioBase64,
        'mimeType': mimeType,
      });

      final text = response.data['transcription'] as String?;
      if (text == null || text.isEmpty) {
        return Failure(
          AppException(message: 'Transcription returned empty result'),
        );
      }

      return Success(text.trim());
    } on FirebaseFunctionsException catch (e) {
      return Failure(
        AppException(message: 'Morfeo transcription error: ${e.message}'),
      );
    } catch (e) {
      return Failure(AppException(message: 'Failed to transcribe audio: $e'));
    }
  }
}
