import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/audio_service.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/data/services/gemini_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/data/dream_draft.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_saved_step_screen.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

// ── Step 2 of the dream creation wizard ────────────────────────────────────
// Offers AI analysis via Morfeo or direct save without analysis.

enum _SaveStage { idle, uploading, transcribing, analyzing, saving, error }

class DreamAnalysisStepScreen extends StatefulWidget {
  const DreamAnalysisStepScreen({super.key, required this.draft});

  final DreamDraft draft;

  @override
  State<DreamAnalysisStepScreen> createState() =>
      _DreamAnalysisStepScreenState();
}

class _DreamAnalysisStepScreenState extends State<DreamAnalysisStepScreen> {
  _SaveStage _stage = _SaveStage.idle;
  String _statusLabel = '';
  String? _errorMessage;

  bool get _isLoading =>
      _stage != _SaveStage.idle && _stage != _SaveStage.error;

  // ── Save orchestration ──────────────────────────────────────────────────

  Future<void> _saveWithAnalysis() => _save(withAi: true);
  Future<void> _saveWithoutAnalysis() => _save(withAi: false);

  Future<void> _save({required bool withAi}) async {
    final userId = FirebaseService.getCurrentUserId();
    if (userId == null || !mounted) return;

    final draft = widget.draft;

    // ── 1. Upload local audio clips ─────────────────────────────────────────
    _setStage(_SaveStage.uploading, 'Subiendo grabaciones...');

    final tempId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final uploadedUrls = <String>[];

    for (var i = 0; i < draft.localAudioPaths.length; i++) {
      final res = await AudioService.instance.uploadAudio(
        userId: userId,
        dreamId: tempId,
        localFilePath: draft.localAudioPaths[i],
        audioIndex: i,
      );
      if (res is Success<String>) uploadedUrls.add(res.value);
    }

    for (final url in draft.removedExistingUrls) {
      AudioService.instance.deleteAudio(audioUrl: url);
    }

    final keptExisting = draft.existingAudioUrls
        .where((u) => !draft.removedExistingUrls.contains(u))
        .toList();
    final finalAudioPaths = [...keptExisting, ...uploadedUrls];

    // ── 2. AI: transcription + analysis via Cloud Functions ─────────────────
    String? transcription;
    String? aiCategory;
    String? aiSummary;
    Map<String, dynamic>? aiAnalysisMap;
    List<String> tags = ['mood:${draft.moodScore}'];

    if (withAi) {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

      // Transcribe audio clips if any
      if (draft.localAudioPaths.isNotEmpty) {
        _setStage(_SaveStage.transcribing, 'Morfeo está escuchando...');
        final parts = <String>[];

        for (final path in draft.localAudioPaths) {
          try {
            final file = File(path);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final audioBase64 = base64Encode(bytes);
              final res = await functions.httpsCallable('transcribeAudio').call(
                {'audioBase64': audioBase64, 'mimeType': 'audio/m4a'},
              );
              final text = res.data['transcription'] as String?;
              if (text != null && text.isNotEmpty) parts.add(text);
            }
          } catch (_) {}
        }

        if (parts.isNotEmpty) transcription = parts.join('\n\n');
      }

      // Build combined text to analyse
      final combined = [
        if (transcription != null && transcription.isNotEmpty) transcription,
        if (draft.text.trim().isNotEmpty) draft.text.trim(),
      ].join('\n\n');

      final analyzeText = combined.isNotEmpty ? combined : draft.text.trim();

      if (analyzeText.isNotEmpty) {
        _setStage(
          _SaveStage.analyzing,
          'Morfeo está interpretando tu sueño...',
        );

        try {
          final res = await functions.httpsCallable('analyzeDream').call({
            'title': draft.title,
            'text': analyzeText,
            'moodScore': draft.moodScore,
          });

          final analysisText = res.data['analysisText'] as String?;
          if (analysisText != null && analysisText.isNotEmpty) {
            final a = DreamAnalysis.fromText(analysisText);
            aiAnalysisMap = a.toMap();
            aiCategory = a.category;
            aiSummary = a.summary;
            tags = [
              'mood:${draft.moodScore}',
              ...a.themes.take(4),
              ...a.emotions.take(3),
            ].toSet().toList();
          }
        } on FirebaseFunctionsException catch (e) {
          // Non-fatal: save without analysis if the CF call fails.
          debugPrint('Morfeo CF error: ${e.code} — ${e.message}');
        } catch (e) {
          debugPrint('Morfeo unexpected error: $e');
        }
      }
    }

    // ── 3. Save to Firestore ─────────────────────────────────────────────────
    _setStage(_SaveStage.saving, 'Guardando en tu diario...');

    final repo = DreamRepositoryImpl();
    final createRes = await repo.createDream(
      userId: userId,
      title: draft.title,
      text: draft.text,
      dreamDate: DateTime.now(),
      moodScore: draft.moodScore,
      tags: tags,
      audioPaths: finalAudioPaths,
      transcription: transcription,
      aiSummary: aiSummary,
      aiCategory: aiCategory ?? 'Pending AI categorization',
    );

    if (!mounted) return;

    if (createRes is Failure<Dream>) {
      setState(() {
        _stage = _SaveStage.error;
        _errorMessage = 'Error al guardar el sueño. Inténtalo de nuevo.';
      });
      return;
    }

    final savedDream = (createRes as Success<Dream>).value;

    // Persist aiAnalysis map if we have one
    if (aiAnalysisMap != null) {
      await repo.updateDream(
        userId: userId,
        dreamId: savedDream.id,
        data: {'aiAnalysis': aiAnalysisMap},
      );
    }

    // Clean up local temp recordings
    for (final path in draft.localAudioPaths) {
      AudioService.instance.deleteLocalFile(path);
    }

    if (!mounted) return;
    // Replace this screen so back returns to the dream list, not back here
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DreamSavedStepScreen(dream: savedDream),
      ),
    );
  }

  void _setStage(_SaveStage stage, String label) {
    if (mounted)
      setState(() {
        _stage = stage;
        _statusLabel = label;
      });
  }

  void _resetError() => setState(() {
    _stage = _SaveStage.idle;
    _errorMessage = null;
  });

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: _isLoading
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: const Text(
          'Analizar sueño',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: _isLoading
              ? _buildLoading()
              : _stage == _SaveStage.error
              ? _buildError()
              : _buildOptions(),
        ),
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MorfeoOrb(size: 80),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _statusLabel,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.surfaceGlass,
              color: AppColors.accentSecondary,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? 'Algo salió mal.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: _resetError,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentPrimary,
              side: BorderSide(
                color: AppColors.accentPrimary.withValues(alpha: 0.5),
              ),
              shape: const StadiumBorder(),
            ),
            child: const Text('Volver a intentar'),
          ),
        ],
      ),
    );
  }

  // ── Main options ─────────────────────────────────────────────────────────

  Widget _buildOptions() {
    // Morfeo is always available via Cloud Functions — no key needed client-side.
    final hasAudio = widget.draft.localAudioPaths.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dream snippet preview
        _DreamSnippetCard(draft: widget.draft),
        const SizedBox(height: AppSpacing.lg),

        // ── Morfeo card ─────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentSecondary.withValues(alpha: 0.16),
                AppColors.bgPrimary,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.accentSecondary.withValues(alpha: 0.35),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MorfeoOrb(size: 36),
                  const SizedBox(width: AppSpacing.xs),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morfeo',
                        style: TextStyle(
                          color: AppColors.accentSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Intérprete de sueños IA',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                hasAudio
                    ? 'Transcribiré tus grabaciones y analizaré las emociones, '
                          'lugares y temas clave que aparecen en tu sueño.'
                    : 'Analizaré las emociones, lugares y temas clave '
                          'que aparecen en tu sueño y lo resumiré para ti.',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _saveWithAnalysis,
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Analizar con Morfeo'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentSecondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Skip button ─────────────────────────────────────────────────
        OutlinedButton.icon(
          onPressed: _saveWithoutAnalysis,
          icon: const Icon(Icons.save_outlined, size: 16),
          label: const Text('Guardar sin análisis'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(color: AppColors.borderSubtle),
            minimumSize: const Size(double.infinity, 46),
            shape: const StadiumBorder(),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

// ── Morfeo glowing orb ────────────────────────────────────────────────────

class _MorfeoOrb extends StatelessWidget {
  const _MorfeoOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.accentSecondary.withValues(alpha: 0.6),
            AppColors.accentSecondary.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSecondary.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.45,
      ),
    );
  }
}

// ── Dream snippet preview card ────────────────────────────────────────────

class _DreamSnippetCard extends StatelessWidget {
  const _DreamSnippetCard({required this.draft});

  final DreamDraft draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            draft.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (draft.text.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              draft.text.trim(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (draft.localAudioPaths.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.mic, color: AppColors.accentPrimary, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${draft.localAudioPaths.length} '
                  'grabación${draft.localAudioPaths.length > 1 ? 'es' : ''}',
                  style: const TextStyle(
                    color: AppColors.accentPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
