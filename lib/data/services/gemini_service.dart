import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
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
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    String extractBlock(String key) {
      final pattern = RegExp('$key:\\s*([\\s\\S]+?)(?=\\n[A-Z_]+:|\$)', caseSensitive: false);
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

/// Service for Gemini AI dream analysis.
class GeminiService {
  GeminiService._();

  static final GeminiService instance = GeminiService._();

  GenerativeModel? _model;

  static const String _modelName = 'gemini-1.5-flash';

  static const String _analysisPromptTemplate = '''
You are a compassionate dream analyst. Analyze the following dream entry and respond in EXACTLY this format (no extra text):

SENTIMENT: [positive/neutral/negative/mixed]
CATEGORY: [one of: Adventure, Nightmare, Fantasy, Romantic, Surreal, Anxiety, Nostalgic, Spiritual, Neutral]
EMOTIONS: [comma-separated list of up to 5 emotions detected, e.g.: joy, fear, confusion]
CHARACTERS: [comma-separated list of up to 5 characters/entities, e.g.: unknown figure, childhood friend]
PLACES: [comma-separated list of up to 3 places, e.g.: forest, old house]
THEMES: [comma-separated list of up to 4 recurring themes, e.g.: pursuit, transformation, loss]
PSYCHOLOGICAL_NOTE: [2-3 sentences of empathetic psychological insight, no diagnosis]
SUMMARY: [1-2 sentence compassionate summary of the dream]

Dream title: {title}
Dream text: {text}
Mood score (1-5): {moodScore}
Context: {context}
''';

  /// Initialize the Gemini service with the provided API key.
  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 512,
      ),
    );
  }

  bool get isInitialized => _model != null;

  /// Analyze a dream entry and return structured insights.
  Future<Result<DreamAnalysis>> analyzeDream({
    required String title,
    required String text,
    int? moodScore,
    String? contextNotes,
  }) async {
    if (_model == null) {
      return Failure(
        AppException(
          message: 'Gemini service not initialized. Call initialize(apiKey) first.',
        ),
      );
    }

    if (text.trim().isEmpty) {
      return Failure(
        ValidationException(message: 'Dream text cannot be empty for analysis'),
      );
    }

    try {
      final prompt = _analysisPromptTemplate
          .replaceAll('{title}', title)
          .replaceAll('{text}', text)
          .replaceAll('{moodScore}', moodScore?.toString() ?? 'not specified')
          .replaceAll('{context}', contextNotes ?? 'none');

      final response = await _model!.generateContent([Content.text(prompt)]);
      final rawText = response.text;

      if (rawText == null || rawText.isEmpty) {
        return Failure(AppException(message: 'Gemini returned an empty response'));
      }

      final analysis = DreamAnalysis.fromText(rawText);
      return Success(analysis);
    } on GenerativeAIException catch (e) {
      return Failure(
        AppException(message: 'Gemini API error: ${e.message}'),
      );
    } catch (e) {
      return Failure(AppException(message: 'Failed to analyze dream: $e'));
    }
  }

  /// Transcribe audio content using Gemini multimodal (requires audio bytes).
  /// Uses inline data for short audio clips.
  Future<Result<String>> transcribeAudioBytes({
    required Uint8List audioBytes,
    String mimeType = 'audio/m4a',
  }) async {
    if (_model == null) {
      return Failure(
        AppException(message: 'Gemini service not initialized.'),
      );
    }

    try {
      const prompt =
          'Transcribe the following audio recording of a person describing their dream. '
          'Output only the transcription text, nothing else.';

      final response = await _model!.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, audioBytes),
        ]),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        return Failure(AppException(message: 'Transcription returned empty result'));
      }

      return Success(text.trim());
    } on GenerativeAIException catch (e) {
      return Failure(AppException(message: 'Gemini transcription error: ${e.message}'));
    } catch (e) {
      return Failure(AppException(message: 'Failed to transcribe audio: $e'));
    }
  }
}
