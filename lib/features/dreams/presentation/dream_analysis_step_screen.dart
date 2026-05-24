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
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_morfeo_result_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_saved_step_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/utils/analysis_language_utils.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';

// ── Step 2 of the dream creation wizard ────────────────────────────────────
// Offers AI analysis via Morfeo or direct save without analysis.

enum _SaveStage { idle, uploading, transcribing, analyzing, saving, error }

class _GeminiEmptyAnalysisException implements Exception {
  const _GeminiEmptyAnalysisException();
}

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
  bool _isMorfeoFlow = true;

  bool get _isLoading =>
      _stage != _SaveStage.idle && _stage != _SaveStage.error;

  // ── Save orchestration ──────────────────────────────────────────────────

  Future<void> _saveWithAnalysis() => _save(withAi: true);
  Future<void> _saveWithoutAnalysis() => _save(withAi: false);

  String _normalizedLocaleCode() {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code.startsWith('es') ? 'es' : 'en';
  }

  Future<void> _save({required bool withAi}) async {
    final l = AppLocalizations.of(context);
    final localeCode = _normalizedLocaleCode();
    final userId = FirebaseService.getCurrentUserId();
    if (userId == null || !mounted) return;

    setState(() {
      _isMorfeoFlow = withAi;
    });

    final draft = widget.draft;

    // ── 1. Upload local audio clips ─────────────────────────────────────────
    _setStage(_SaveStage.uploading, l.dreamAnalysisUploadingRecordings);

    final tempId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final uploadedUrls = <String>[];
    int uploadFailures = 0;

    for (var i = 0; i < draft.localAudioPaths.length; i++) {
      final res = await AudioService.instance.uploadAudio(
        userId: userId,
        dreamId: tempId,
        localFilePath: draft.localAudioPaths[i],
        audioIndex: i,
      );
      if (res is Success<String>) {
        uploadedUrls.add(res.value);
      } else {
        uploadFailures++;
      }
    }

    if (!withAi && uploadFailures > 0) {
      await _rollbackUploadedAudio(uploadedUrls);
      if (!mounted) return;
      _setStage(_SaveStage.idle, '');
      await _showSaveWarningDialog(
        title: l.dreamAnalysisAudioUploadFailedTitle,
        message: l.dreamAnalysisAudioUploadFailedMessage,
      );
      return;
    }

    for (final url in draft.removedExistingUrls) {
      AudioService.instance.deleteAudio(audioUrl: url);
    }

    final keptExisting = draft.existingAudioUrls
        .where((u) => !draft.removedExistingUrls.contains(u))
        .toList();
    final finalAudioPaths = [...keptExisting, ...uploadedUrls];

    if (!withAi && draft.text.trim().isEmpty && finalAudioPaths.isEmpty) {
      if (!mounted) return;
      _setStage(_SaveStage.idle, '');
      await _showSaveWarningDialog(
        title: l.dreamAnalysisMissingContentTitle,
        message: l.dreamAnalysisMissingContentMessage,
      );
      return;
    }

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
        _setStage(_SaveStage.transcribing, l.dreamAnalysisMorfeoListening);
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
          } on FirebaseFunctionsException catch (e) {
            final message = '${e.message ?? ''} ${e.details ?? ''}'
                .toLowerCase();
            final isQuotaOrAvailabilityIssue =
                e.code == 'resource-exhausted' ||
                e.code == 'unavailable' ||
                message.contains('429 too many requests') ||
                message.contains('prepayment credits are depleted') ||
                message.contains('quota');

            if (isQuotaOrAvailabilityIssue) {
              debugPrint(
                'Morfeo transcription degraded: $e. Continuing with title/text only.',
              );
              continue;
            }

            await _rollbackUploadedAudio(uploadedUrls);
            if (!mounted) return;
            _setStage(_SaveStage.idle, '');
            await _showMorfeoWarningDialog(
              title: l.dreamAnalysisMorfeoTranscriptionFailedTitle,
              message: l.dreamAnalysisMorfeoTranscriptionFailedMessage,
            );
            return;
          } catch (_) {
            await _rollbackUploadedAudio(uploadedUrls);
            if (!mounted) return;
            _setStage(_SaveStage.idle, '');
            await _showMorfeoWarningDialog(
              title: l.dreamAnalysisMorfeoTranscriptionFailedTitle,
              message: l.dreamAnalysisMorfeoTranscriptionReadFailedMessage,
            );
            return;
          }
        }

        if (parts.isNotEmpty) transcription = parts.join('\n\n');

        final hasTypedText = draft.text.trim().isNotEmpty;
        if (!hasTypedText && _isTranscriptionTooSmall(transcription)) {
          await _rollbackUploadedAudio(uploadedUrls);
          if (!mounted) return;
          _setStage(_SaveStage.idle, '');
          await _showMorfeoWarningDialog(
            title: l.dreamAnalysisInsufficientInfoTitle,
            message: l.dreamAnalysisInsufficientInfoMessage,
          );
          return;
        }
      }

      // Build combined text to analyse
      final combined = [
        if (transcription != null && transcription.isNotEmpty) transcription,
        if (draft.text.trim().isNotEmpty) draft.text.trim(),
      ].join('\n\n');

      final analyzeText = combined.isNotEmpty ? combined : draft.text.trim();

      if (analyzeText.isNotEmpty) {
        _setStage(_SaveStage.analyzing, l.dreamAnalysisMorfeoInterpreting);

        try {
          final result = await GeminiService.instance.analyzeDream(
            title: draft.title,
            text: analyzeText,
            moodScore: draft.moodScore,
            language: localeCode,
          );

          if (result is Failure<DreamAnalysis>) {
            throw (result).exception;
          }

          final localizedAnalysis = AnalysisLanguageUtils.coerceToLocale(
            analysis: (result as Success<DreamAnalysis>).value,
            localeCode: localeCode,
            dreamText: analyzeText,
          );

          final alignedAnalysis = AnalysisLanguageUtils.alignWithDreamSignals(
            analysis: localizedAnalysis,
            dreamText: analyzeText,
            localeCode: localeCode,
          );

          debugPrint(
            '[DreamAnalysisStep] alignedAnalysis stats: '
            'sentiment=${alignedAnalysis.sentiment}, '
            'category=${alignedAnalysis.category}, '
            'summaryLength=${alignedAnalysis.summary.length}, '
            'psychNoteLength=${alignedAnalysis.psychologicalNote.length}, '
            'emotions=${alignedAnalysis.emotions.length}, '
            'characters=${alignedAnalysis.characters.length}, '
            'places=${alignedAnalysis.places.length}, '
            'themes=${alignedAnalysis.themes.length}',
          );

          if (!_hasMinimumGeminiContent(alignedAnalysis)) {
            throw const _GeminiEmptyAnalysisException();
          }

          aiAnalysisMap = alignedAnalysis.toMap();
          aiCategory = alignedAnalysis.category;
          aiSummary = alignedAnalysis.summary;
          tags = <String>{
            'mood:${draft.moodScore}',
            ...alignedAnalysis.themes.take(4),
            ...alignedAnalysis.emotions.take(3),
          }.toList();

          if (aiSummary.trim().isEmpty) {
            debugPrint(
              '[DreamAnalysisStep] WARNING: summary is empty but analysis was accepted by minimum-content rule.',
            );
          }
        } on AppException catch (e) {
          debugPrint('Morfeo service error: ${e.message}');
          await _rollbackUploadedAudio(uploadedUrls);
          if (!mounted) return;
          _setStage(_SaveStage.idle, '');
          await _showMorfeoWarningDialog(
            title: l.dreamAnalysisMorfeoAnalyzeFailedTitle,
            message: _mapMorfeoAnalyzeError(e, l),
          );
          return;
        } on _GeminiEmptyAnalysisException {
          await _rollbackUploadedAudio(uploadedUrls);
          if (!mounted) return;
          _setStage(_SaveStage.idle, '');

          final shouldRetry = await _showMorfeoWarningDialog(
            title: l.dreamAnalysisMorfeoAnalyzeFailedTitle,
            message: _emptyAnalysisMessage(localeCode),
            retryLabel: l.dreamsListRetry,
          );

          if (shouldRetry && mounted) {
            await _saveWithAnalysis();
          }
          return;
        } catch (e) {
          debugPrint('Morfeo unexpected error: $e');
          await _rollbackUploadedAudio(uploadedUrls);
          if (!mounted) return;
          _setStage(_SaveStage.idle, '');
          await _showMorfeoWarningDialog(
            title: l.dreamAnalysisMorfeoAnalyzeFailedTitle,
            message: l.dreamAnalysisMorfeoAnalyzeUnexpectedMessage,
          );
          return;
        }
      }
    }

    // ── 3. Save to Firestore ─────────────────────────────────────────────────
    _setStage(_SaveStage.saving, l.dreamAnalysisSavingToJournal);

    final repo = DreamRepositoryImpl();
    final createRes = await repo.createDream(
      userId: userId,
      title: draft.title,
      text: draft.text,
      dreamDate: draft.dreamDate,
      moodScore: draft.moodScore,
      tags: tags,
      audioPaths: finalAudioPaths,
      transcription: transcription,
      aiSummary: aiSummary,
      aiCategory: aiCategory,
    );

    if (!mounted) return;

    if (createRes is Failure<Dream>) {
      if (!withAi) {
        final hasAnyAudioInput =
            draft.localAudioPaths.isNotEmpty ||
            draft.existingAudioUrls
                .where((u) => !draft.removedExistingUrls.contains(u))
                .isNotEmpty;
        _setStage(_SaveStage.idle, '');
        await _showSaveWarningDialog(
          title: l.dreamAnalysisSaveFailedTitle,
          message: hasAnyAudioInput
              ? l.dreamAnalysisSaveFailedAudioMessage
              : l.dreamAnalysisSaveFailedConnectionMessage,
          isError: true,
        );
      } else {
        setState(() {
          _stage = _SaveStage.error;
          _errorMessage = l.dreamAnalysisSaveErrorRetry;
        });
      }
      return;
    }

    var savedDream = (createRes as Success<Dream>).value;

    // Persist aiAnalysis map if we have one
    if (aiAnalysisMap != null) {
      final aiByLanguage = <String, dynamic>{localeCode: aiAnalysisMap};
      debugPrint(
        '[DreamAnalysisStep] Persisting analysis: '
        'locale=$localeCode, '
        'aiCategoryLength=${(aiCategory ?? '').length}, '
        'aiSummaryLength=${(aiSummary ?? '').length}, '
        'keys=${aiAnalysisMap.keys.toList()}',
      );
      await repo.updateDream(
        userId: userId,
        dreamId: savedDream.id,
        data: {
          'aiAnalysis': aiAnalysisMap,
          'aiAnalysisByLanguage': aiByLanguage,
          'aiCategory': aiCategory,
          'aiSummary': aiSummary,
        },
      );

      savedDream = savedDream.copyWith(
        aiAnalysis: aiAnalysisMap,
        aiAnalysisByLanguage: aiByLanguage,
      );
    }

    // Clean up local temp recordings
    for (final path in draft.localAudioPaths) {
      AudioService.instance.deleteLocalFile(path);
    }

    if (!mounted) return;
    // Replace this screen so back returns to the dream list, not back here
    if (withAi && aiAnalysisMap != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DreamMorfeoResultScreen(
            dream: savedDream,
            aiAnalysis: aiAnalysisMap!,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DreamSavedStepScreen(dream: savedDream),
        ),
      );
    }
  }

  void _setStage(_SaveStage stage, String label) {
    if (mounted) {
      setState(() {
        _stage = stage;
        _statusLabel = label;
      });
    }
  }

  Future<void> _rollbackUploadedAudio(List<String> audioUrls) async {
    for (final url in audioUrls) {
      await AudioService.instance.deleteAudio(audioUrl: url);
    }
  }

  bool _isTranscriptionTooSmall(String? transcription) {
    if (transcription == null) return true;
    final normalized = transcription.trim().replaceAll(RegExp(r'\s+'), ' ');
    return normalized.isEmpty;
  }

  bool _hasMinimumGeminiContent(DreamAnalysis analysis) {
    return analysis.summary.trim().isNotEmpty ||
      analysis.psychologicalNote.trim().isNotEmpty ||
      analysis.themes.isNotEmpty ||
      analysis.emotions.isNotEmpty ||
      analysis.category.trim().isNotEmpty ||
      analysis.sentiment.trim().isNotEmpty;
  }

  Future<bool> _showMorfeoWarningDialog({
    required String title,
    required String message,
    String? retryLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (ctx) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentSecondary.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentSecondary.withValues(alpha: 0.12),
                blurRadius: 36,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MorpheusOrb(size: 64),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              if (retryLabel != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentSecondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(retryLabel),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: retryLabel == null
                    ? FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentSecondary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          AppLocalizations.of(context).dreamAnalysisUnderstood,
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentSecondary,
                          side: BorderSide(
                            color: AppColors.accentSecondary.withValues(alpha: 0.55),
                          ),
                          minimumSize: const Size.fromHeight(46),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          AppLocalizations.of(context).dreamAnalysisUnderstood,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ).then((value) => value ?? false);
  }

  String _emptyAnalysisMessage(String localeCode) {
    if (localeCode == 'es') {
      return 'Morfeo no devolvió datos suficientes para analizar este sueño. Puedes reintentarlo ahora.';
    }

    return 'Morpheus did not return enough data to analyze this dream. You can try again now.';
  }

  String _mapMorfeoAnalyzeError(AppException error, AppLocalizations l) {
    final msg = error.message.toLowerCase();

    if (msg.contains('resource-exhausted') ||
        msg.contains('quota') ||
        msg.contains('429') ||
        msg.contains('prepayment credits are depleted')) {
      return l.dreamAnalysisMorfeoAnalyzeFailedMessage;
    }

    if (msg.contains('unavailable') || msg.contains('timeout')) {
      return l.dreamAnalysisMorfeoAnalyzeFailedMessage;
    }

    if (msg.contains('no json object found') ||
        msg.contains('invalid json') ||
        msg.contains('json')) {
      return l.dreamAnalysisMorfeoAnalyzeUnexpectedMessage;
    }

    return l.dreamAnalysisMorfeoAnalyzeFailedMessage;
  }

  String _aiDisclaimerMessage() {
    final localeCode = _normalizedLocaleCode();
    if (localeCode == 'es') {
      return 'Aviso: el contenido generado por IA puede contener errores o interpretaciones imprecisas.';
    }

    return 'Notice: AI-generated content may contain mistakes or inaccurate interpretations.';
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
        title: Text(
          AppLocalizations.of(context).dreamAnalysisTitle,
          style: const TextStyle(
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
          _isMorfeoFlow
              ? const MorpheusOrb(size: 156)
              : Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentPrimary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.accentPrimary.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.save_rounded,
                    color: AppColors.accentPrimary,
                    size: 52,
                  ),
                ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _statusLabel,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          const SizedBox(
            width: 260,
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

  Future<void> _showSaveWarningDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final accentColor = isError ? AppColors.error : AppColors.accentPrimary;
    final foregroundColor = isError ? Colors.white : AppColors.bgPrimary;

    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.45),
                  ),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: foregroundColor,
                    minimumSize: const Size.fromHeight(46),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    AppLocalizations.of(context).dreamAnalysisUnderstood,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildError() {
    final l = AppLocalizations.of(context);
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
            _errorMessage ?? l.dreamAnalysisSomethingWentWrong,
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
            child: Text(l.dreamsListRetry),
          ),
        ],
      ),
    );
  }

  // ── Main options ─────────────────────────────────────────────────────────

  Widget _buildOptions() {
    final l = AppLocalizations.of(context);
    // Morfeo is always available via Cloud Functions — no key needed client-side.
    final hasAudio = widget.draft.localAudioPaths.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 760;
        final verticalGap = isCompactHeight ? AppSpacing.lg : AppSpacing.xl;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DreamSnippetCard(draft: widget.draft),
                SizedBox(height: verticalGap),
                _MorfeoInfoCard(hasAudio: hasAudio),
                const SizedBox(height: AppSpacing.md),
                _AiDisclaimerCard(message: _aiDisclaimerMessage()),
                SizedBox(height: verticalGap),
                FilledButton.icon(
                  onPressed: _saveWithAnalysis,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(l.dreamAnalysisAnalyzeWithMorfeo),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentSecondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _saveWithoutAnalysis,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(l.dreamAnalysisSaveWithoutAnalysis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentPrimary,
                    side: BorderSide(
                      color: AppColors.accentPrimary.withValues(alpha: 0.8),
                      width: 1.4,
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'TU PRIVACIDAD ES NUESTRA PRIORIDAD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Dream snippet preview card ────────────────────────────────────────────

class _DreamSnippetCard extends StatelessWidget {
  const _DreamSnippetCard({required this.draft});

  final DreamDraft draft;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dreamBody = draft.text.trim();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceGlass,
            AppColors.accentPrimary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.32),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (draft.title.trim().isNotEmpty) ...[
            Text(
              draft.title.trim(),
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
          ],
          if (dreamBody.isNotEmpty)
            Text(
              '"$dreamBody"',
              style: const TextStyle(
                fontFamily: 'Lora',
                fontStyle: FontStyle.italic,
                color: AppColors.accentPrimary,
                fontSize: 15,
                height: 1.7,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              l.dreamAnalysisMissingContentTitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          if (draft.localAudioPaths.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.mic, color: AppColors.accentPrimary, size: 14),
                const SizedBox(width: 4),
                Text(
                  l.dreamAnalysisAudioRecordingsCount(
                    draft.localAudioPaths.length,
                  ),
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

class _AiDisclaimerCard extends StatelessWidget {
  const _AiDisclaimerCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MorfeoInfoCard extends StatelessWidget {
  const _MorfeoInfoCard({required this.hasAudio});

  final bool hasAudio;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceGlass,
            AppColors.accentSecondary.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.35),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          const MorpheusOrb(size: 146),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.welcomeMorpheusTitle,
            style: const TextStyle(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasAudio
                ? l.dreamAnalysisCardBodyWithAudio
                : l.dreamAnalysisCardBodyWithoutAudio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
