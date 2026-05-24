import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/app/theme/app_text_styles.dart';
import 'package:hypnos_dreamjournal/core/config/app_settings.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/gemini_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/errors/error_messages.dart';
import 'package:hypnos_dreamjournal/shared/utils/analysis_language_utils.dart';
import 'package:hypnos_dreamjournal/shared/utils/intensity_utils.dart';
import 'package:hypnos_dreamjournal/shared/widgets/audio_player_widget.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_form_screen.dart';

class DreamDetailScreen extends StatefulWidget {
  const DreamDetailScreen({super.key, required this.dream});

  final Dream dream;

  @override
  State<DreamDetailScreen> createState() => _DreamDetailScreenState();
}

class _DreamDetailScreenState extends State<DreamDetailScreen> {
  final DreamRepository _dreamRepository = DreamRepositoryImpl();
  late Dream _dream;

  bool _isDeleting = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Sprint 3: AI analysis state
  bool _isAnalyzing = false;
  DreamAnalysis? _analysis;
  String? _analysisError;
  String? _lastLocaleCode;
  bool _isEnsuringLocaleAnalysis = false;

  // Sprint 4: AI enabled toggle
  bool _aiEnabled = true;

  @override
  void initState() {
    super.initState();
    _dream = widget.dream;
    _loadAiEnabled();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocaleCode = _currentLocaleCode();

    if (_lastLocaleCode == null) {
      _lastLocaleCode = currentLocaleCode;
      _ensureLocaleAnalysisForCurrentLanguage();
      return;
    }

    if (_lastLocaleCode == currentLocaleCode) {
      return;
    }

    _lastLocaleCode = currentLocaleCode;

    if (_analysis != null) {
      setState(() {
        _analysis = null;
      });
    }

    _ensureLocaleAnalysisForCurrentLanguage();
  }

  Future<void> _loadAiEnabled() async {
    final enabled = await AppSettings.instance.getAiEnabled();
    if (!mounted) return;

    setState(() => _aiEnabled = enabled);
    if (enabled) {
      _ensureLocaleAnalysisForCurrentLanguage();
    }
  }

  String _normalizeLocaleCode(String code) {
    return AnalysisLanguageUtils.normalizeLocaleCode(code);
  }

  String _currentLocaleCode() {
    return _normalizeLocaleCode(Localizations.localeOf(context).languageCode);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  Map<String, dynamic>? _analysisForLocale(String localeCode) {
    final byLanguage = _dream.aiAnalysisByLanguage;
    if (byLanguage == null || byLanguage.isEmpty) return null;

    final exact = _asMap(byLanguage[localeCode]);
    if (exact != null && exact.isNotEmpty) return exact;

    for (final entry in byLanguage.entries) {
      if (_normalizeLocaleCode(entry.key) == localeCode) {
        final mapped = _asMap(entry.value);
        if (mapped != null && mapped.isNotEmpty) {
          return mapped;
        }
      }
    }

    return null;
  }

  bool _hasOtherLanguageAnalysis(String localeCode) {
    final byLanguage = _dream.aiAnalysisByLanguage;
    if (byLanguage == null || byLanguage.isEmpty) return false;

    for (final entry in byLanguage.entries) {
      if (_normalizeLocaleCode(entry.key) == localeCode) continue;
      final mapped = _asMap(entry.value);
      if (mapped != null && mapped.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Future<void> _ensureLocaleAnalysisForCurrentLanguage() async {
    if (!_aiEnabled || !mounted || _isAnalyzing || _isEnsuringLocaleAnalysis) {
      return;
    }

    final localeCode = _currentLocaleCode();
    if (_analysisForLocale(localeCode) != null) {
      return;
    }

    if (!_hasOtherLanguageAnalysis(localeCode)) {
      return;
    }

    _isEnsuringLocaleAnalysis = true;
    try {
      await _runAnalysis(silent: true, forcedLocaleCode: localeCode);
    } finally {
      _isEnsuringLocaleAnalysis = false;
    }
  }

  DreamAnalysis? get _storedAnalysis {
    final data = _analysisForLocale(_currentLocaleCode()) ?? _dream.aiAnalysis;
    if (data == null) return null;

    List<String> readList(String key) {
      final raw = data[key];
      if (raw is List) {
        return raw
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return const [];
    }

    final parsed = DreamAnalysis(
      sentiment: data['sentiment'] as String? ?? '',
      category: data['category'] as String? ?? '',
      emotions: readList('emotions'),
      characters: readList('characters'),
      places: readList('places'),
      themes: readList('themes'),
      psychologicalNote: data['psychologicalNote'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
    );

    final localized = AnalysisLanguageUtils.coerceToLocale(
      analysis: parsed,
      localeCode: _currentLocaleCode(),
      dreamText: _dream.text,
    );

    return AnalysisLanguageUtils.alignWithDreamSignals(
      analysis: localized,
      dreamText: _dream.text,
      localeCode: _currentLocaleCode(),
    );
  }

  DreamAnalysis? get _resolvedAnalysis => _analysis ?? _storedAnalysis;

  String _intensityLabel(AppLocalizations l) {
    return IntensityUtils.label(l, _dream.moodScore);
  }

  Color _intensityColor() => IntensityUtils.color(_dream.moodScore);

  bool _isPendingAiCategoryLabel(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'pending ai categorization' ||
        normalized == 'pendiente de categorizacion ia' ||
        normalized == 'pendiente de categorización ia';
  }

  String _displayAiCategory(AppLocalizations l) {
    final category = _analysisCategory();
    if (category == null || _isPendingAiCategoryLabel(category)) {
      return l.dreamDetailAiCategoryPending;
    }
    return category;
  }

  String? _analysisCategory() {
    final analysis = _resolvedAnalysis;
    final category = analysis?.category.trim();
    if (category != null &&
        category.isNotEmpty &&
        !_isPendingAiCategoryLabel(category)) {
      return category;
    }
    final fallback = _dream.aiCategory?.trim();
    if (fallback != null &&
        fallback.isNotEmpty &&
        !_isPendingAiCategoryLabel(fallback)) {
      return fallback;
    }
    return null;
  }

  String? _analysisSummary() {
    final analysis = _resolvedAnalysis;
    final summary = analysis?.summary.trim();
    if (summary != null && summary.isNotEmpty) return summary;
    final fallback = _dream.aiSummary?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  Future<void> _refreshDream() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    final result = await _dreamRepository.getDreamById(
      userId: _dream.userId,
      dreamId: _dream.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isRefreshing = false;
      if (result is Success<Dream>) {
        _dream = result.value;
      } else {
        _errorMessage = AppError.handle(
          (result as Failure<Dream>).exception,
          'DreamDetail.refresh',
        );
      }
    });
  }

  Future<void> _editDream() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DreamFormScreen(dream: _dream)),
    );

    if (updated == true) {
      await _refreshDream();
    }
  }

  Future<void> _deleteDream() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (ctx) {
        final dl = AppLocalizations.of(ctx);
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2230),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.30),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.10),
                  blurRadius: 30,
                  spreadRadius: -6,
                ),
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.error.withValues(alpha: 0.24),
                        AppColors.error.withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: AppColors.error,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  dl.dreamDetailDeleteDialogTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dl.dreamDetailDeleteDialogContent,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.borderSubtle.withValues(alpha: 0.8),
                          ),
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(dl.dreamDetailDeleteCancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          dl.dreamDetailDeleteConfirm,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    final result = await _dreamRepository.deleteDream(
      userId: _dream.userId,
      dreamId: _dream.id,
    );

    if (!mounted) {
      return;
    }

    if (result is Success<void>) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isDeleting = false;
      _errorMessage = AppError.handle(
        (result as Failure<void>).exception,
        'DreamDetail.delete',
      );
    });
  }

  Future<void> _runAnalysis({
    bool silent = false,
    String? forcedLocaleCode,
  }) async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      if (!silent) {
        _analysisError = null;
      }
    });

    if (!mounted) return;

    final localeCode = forcedLocaleCode ?? _currentLocaleCode();

    final analysisInput = await _resolveAnalysisInput();
    if (!mounted) return;

    if (analysisInput.analysisText.trim().isEmpty) {
      setState(() {
        _isAnalyzing = false;
        if (!silent) {
          _analysisError = _audioOnlyAnalysisUnavailableMessage();
        }
      });
      return;
    }

    final result = await GeminiService.instance.analyzeDream(
      title: _dream.title,
      text: analysisInput.analysisText,
      moodScore: _dream.moodScore,
      contextNotes: _dream.contextNotes,
      language: localeCode,
    );

    if (!mounted) return;

    if (result is Success<DreamAnalysis>) {
      final localizedAnalysis = AnalysisLanguageUtils.coerceToLocale(
        analysis: result.value,
        localeCode: localeCode,
        dreamText: analysisInput.analysisText,
      );
      final alignedAnalysis = AnalysisLanguageUtils.alignWithDreamSignals(
        analysis: localizedAnalysis,
        dreamText: analysisInput.analysisText,
        localeCode: localeCode,
      );
      final analysisMap = alignedAnalysis.toMap();
      final mergedByLanguage = Map<String, dynamic>.from(
        _dream.aiAnalysisByLanguage ?? const <String, dynamic>{},
      );
      mergedByLanguage[localeCode] = analysisMap;

      await _dreamRepository.updateDream(
        userId: _dream.userId,
        dreamId: _dream.id,
        data: {
          'aiCategory': alignedAnalysis.category,
          'aiSummary': alignedAnalysis.summary,
          'transcription': analysisInput.transcriptionForStorage,
          'aiAnalysis': analysisMap,
          'aiAnalysisByLanguage': mergedByLanguage,
        },
      );

      setState(() {
        _analysis = alignedAnalysis;
        _isAnalyzing = false;
        _dream = _dream.copyWith(
          aiCategory: alignedAnalysis.category,
          aiSummary: alignedAnalysis.summary,
          transcription: analysisInput.transcriptionForStorage,
          aiAnalysis: analysisMap,
          aiAnalysisByLanguage: mergedByLanguage,
        );
      });
    } else {
      final failure = result as Failure<DreamAnalysis>;
      setState(() {
        _isAnalyzing = false;
        if (!silent) {
          _analysisError = _mapMorfeoAnalyzeError(failure.exception);
        }
      });
    }
  }

  String _audioOnlyAnalysisUnavailableMessage() {
    final isEs = _currentLocaleCode() == 'es';
    if (isEs) {
      return 'No se pudo obtener una transcripción del audio para analizar este sueño.';
    }

    return 'Could not obtain an audio transcription to analyze this dream.';
  }

  String _mapMorfeoAnalyzeError(Exception error) {
    final l = AppLocalizations.of(context);
    final message = error is AppException
        ? error.message.toLowerCase()
        : error.toString().toLowerCase();

    if (message.contains('resource-exhausted') ||
        message.contains('quota') ||
        message.contains('429') ||
        message.contains('prepayment credits are depleted')) {
      return l.dreamAnalysisMorfeoAnalyzeFailedMessage;
    }

    if (message.contains('unavailable') || message.contains('timeout')) {
      return l.dreamAnalysisMorfeoAnalyzeFailedMessage;
    }

    if (message.contains('no json object found') ||
        message.contains('invalid json') ||
        message.contains('json')) {
      return l.dreamAnalysisMorfeoAnalyzeUnexpectedMessage;
    }

    return l.dreamAnalysisMorfeoAnalyzeFailedMessage;
  }

  Future<_DreamAnalysisInput> _resolveAnalysisInput() async {
    final text = _dream.text.trim();
    var transcription = _dream.transcription?.trim() ?? '';

    if (transcription.isEmpty && _dream.audioPaths.isNotEmpty) {
      transcription = await _transcribeStoredAudios();
      if (!mounted) {
        return const _DreamAnalysisInput(analysisText: '');
      }

      if (transcription.isNotEmpty) {
        setState(() {
          _dream = _dream.copyWith(transcription: transcription);
        });
      }
    }

    final parts = <String>[];
    if (text.isNotEmpty) {
      parts.add(text);
    }
    if (transcription.isNotEmpty) {
      parts.add(transcription);
    }

    final analysisText = parts.join('\n\n').trim();

    return _DreamAnalysisInput(
      analysisText: analysisText,
      transcriptionForStorage: transcription.isNotEmpty
          ? transcription
          : _dream.transcription,
    );
  }

  Future<String> _transcribeStoredAudios() async {
    final parts = <String>[];

    for (final audioUrl in _dream.audioPaths) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(audioUrl);
        final bytes = await ref.getData(12 * 1024 * 1024);
        if (bytes == null || bytes.isEmpty) {
          continue;
        }

        final transcriptionResult = await GeminiService.instance
            .transcribeAudioBytes(audioBytes: bytes);

        if (transcriptionResult is Success<String>) {
          final text = transcriptionResult.value.trim();
          if (text.isNotEmpty) {
            parts.add(text);
          }
        }
      } catch (_) {
        // Best-effort transcription for legacy audio-only dreams.
      }
    }

    return parts.join('\n\n').trim();
  }

  void _shareDream() {
    final l = AppLocalizations.of(context);
    final title = _dream.title.trim().isNotEmpty
        ? _dream.title.trim()
        : l.dreamsListUntitled;
    final body = _dream.text.trim();
    final shareText = body.isNotEmpty
        ? l.dreamSavedShareWithBody(title, body)
        : l.dreamSavedShareWithoutBody(title);
    Share.share(shareText, subject: title);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.dreamDetailTitle),
        actions: [
          IconButton(
            onPressed: _isRefreshing ? null : _refreshDream,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Text(
              _dream.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat.yMMMd().add_jm().format(_dream.dreamDate),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _DreamNarrativeCard(
              intensityLabel: _intensityLabel(l),
              intensityColor: _intensityColor(),
              text: _dream.text.isNotEmpty ? _dream.text : '-',
            ),
            const SizedBox(height: AppSpacing.md),
            _DreamMetaCard(
              intensityLabel: _intensityLabel(l),
              aiCategory: _displayAiCategory(l),
            ),
            const SizedBox(height: AppSpacing.md),
            // ── Audio players ─────────────────────────────────────────────
            if (_dream.hasAudio) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l.dreamDetailAudioSection,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              for (var i = 0; i < _dream.audioPaths.length; i++) ...[
                const SizedBox(height: AppSpacing.xs),
                if (_dream.audioPaths.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'Audio ${i + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                AudioPlayerWidget(remoteUrl: _dream.audioPaths[i]),
              ],
            ],
            // ── Transcription ─────────────────────────────────────────────
            if (_dream.transcription != null &&
                _dream.transcription!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l.dreamDetailTranscription,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    _dream.transcription!,
                    style: AppTextStyles.dreamBody.copyWith(fontSize: 15),
                  ),
                ),
              ),
            ],
            // ── AI Analysis ───────────────────────────────────────────────
            const SizedBox(height: AppSpacing.md),
            if (_aiEnabled)
              _AiAnalysisSection(
                analysis: _resolvedAnalysis,
                aiSummary: _analysisSummary(),
                isAnalyzing: _isAnalyzing,
                analysisError: _analysisError,
                onRunAnalysis: () => _runAnalysis(),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      AppLocalizations.of(context).profileAiEnabledHint,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            if ((_resolvedAnalysis != null ||
                    (_analysisSummary()?.isNotEmpty ?? false)) &&
                _dream.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _GeneratedVisualizationCard(
                label: 'Visualizacion generada',
                title: _displayAiCategory(l),
              ),
            ],
            // ─────────────────────────────────────────────────────────────
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _DetailActionButtons(
              isDeleting: _isDeleting,
              onEdit: _editDream,
              onDelete: _deleteDream,
              onShare: _shareDream,
              editLabel: l.dreamDetailEditButton,
              deleteLabel: l.dreamDetailDeleteButton,
              shareLabel: l.dreamSavedShareSection,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _DreamAnalysisInput {
  const _DreamAnalysisInput({
    required this.analysisText,
    this.transcriptionForStorage,
  });

  final String analysisText;
  final String? transcriptionForStorage;
}

/// Widget that displays the AI analysis section in the dream detail.
class _AiAnalysisSection extends StatelessWidget {
  const _AiAnalysisSection({
    required this.isAnalyzing,
    required this.onRunAnalysis,
    this.analysis,
    this.aiSummary,
    this.analysisError,
  });

  final bool isAnalyzing;
  final VoidCallback onRunAnalysis;
  final DreamAnalysis? analysis;
  final String? aiSummary;
  final String? analysisError;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEs = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('es');
    final disclaimerText = isEs
        ? 'Aviso: el contenido generado por IA puede contener errores o interpretaciones imprecisas.'
        : 'Notice: AI-generated content may contain mistakes or inaccurate interpretations.';
    final hasPreviousAnalysis =
      analysis != null || (aiSummary != null && aiSummary!.trim().isNotEmpty);
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final rerunLabel = localeCode.startsWith('es')
      ? 'Volver a ejecutar análisis IA'
      : 'Run AI analysis again';
    final analyzeButtonLabel = isAnalyzing
      ? l.dreamDetailAnalyzing
      : hasPreviousAnalysis
        ? rerunLabel
        : l.dreamDetailAnalyzeButton;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentSecondary.withValues(alpha: 0.16),
            AppColors.surfaceGlass,
            AppColors.accentPrimary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accentSecondary.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSecondary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: MorpheusOrb(
                    size: 24,
                    showBlueGlow: false,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l.welcomeMorpheusTitle,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSecondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  analysis?.category ?? l.dreamDetailAiCategoryPending,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accentSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          if (analysisError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              analysisError!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ],
          if (analysis != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.accentSecondary.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis!.category,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (analysis!.summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(analysis!.summary, style: AppTextStyles.dreamBody),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _AnalysisFieldCard(
                  label: l.dreamDetailAiSentiment,
                  value: analysis!.sentiment,
                ),
                if (analysis!.emotions.isNotEmpty)
                  _AnalysisFieldCard(
                    label: l.dreamDetailAiEmotions,
                    value: analysis!.emotions.join(', '),
                  ),
                if (analysis!.characters.isNotEmpty)
                  _AnalysisFieldCard(
                    label: l.dreamDetailAiCharacters,
                    value: analysis!.characters.join(', '),
                  ),
                if (analysis!.places.isNotEmpty)
                  _AnalysisFieldCard(
                    label: l.dreamDetailAiPlaces,
                    value: analysis!.places.join(', '),
                  ),
                if (analysis!.themes.isNotEmpty)
                  _AnalysisFieldCard(
                    label: l.dreamDetailAiThemes,
                    value: analysis!.themes.join(', '),
                  ),
              ],
            ),
            if (analysis!.psychologicalNote.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.accentSecondary.withValues(alpha: 0.20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.dreamDetailAiPsychNote,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accentSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analysis!.psychologicalNote,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ] else if (aiSummary != null && aiSummary!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(aiSummary!, style: AppTextStyles.dreamBody),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              isEs
                  ? '${l.welcomeMorpheusTitle} todavía no ha analizado este sueño.'
                  : '${l.welcomeMorpheusTitle} has not analyzed this dream yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.85),
              ),
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
                    disclaimerText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isAnalyzing ? null : onRunAnalysis,
              icon: isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 16),
              label: Text(analyzeButtonLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentSecondary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamNarrativeCard extends StatelessWidget {
  const _DreamNarrativeCard({
    required this.text,
    required this.intensityLabel,
    required this.intensityColor,
  });

  final String text;
  final String intensityLabel;
  final Color intensityColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.accentPrimary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Relato del sueño',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: intensityColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  intensityLabel,
                  style: TextStyle(
                    color: intensityColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.dreamBody.copyWith(
              height: 1.55,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamMetaCard extends StatelessWidget {
  const _DreamMetaCard({
    required this.intensityLabel,
    required this.aiCategory,
  });

  final String intensityLabel;
  final String aiCategory;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _MetaLine(
            icon: Icons.bolt_rounded,
            label: l.dreamDetailMoodScore,
            value: intensityLabel,
            valueColor: AppColors.accentPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetaLine(
            icon: Icons.auto_awesome_outlined,
            label: l.dreamDetailAiCategory,
            value: aiCategory,
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? AppColors.textPrimary,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneratedVisualizationCard extends StatelessWidget {
  const _GeneratedVisualizationCard({
    required this.label,
    required this.title,
  });

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEs = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('es');
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.accentSecondary.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1740),
            AppColors.accentSecondary.withValues(alpha: 0.45),
            const Color(0xFF0E1125),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -36,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEs
                      ? 'Una reinterpretación visual suave del sueño, en el lenguaje de ${l.welcomeMorpheusTitle}.'
                      : 'A soft visual reinterpretation of the dream, in ${l.welcomeMorpheusTitle}\'s language.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionButtons extends StatelessWidget {
  const _DetailActionButtons({
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.editLabel,
    required this.deleteLabel,
    required this.shareLabel,
  });

  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final String editLabel;
  final String deleteLabel;
  final String shareLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPrimary,
                      AppColors.accentSecondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: Text(editLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(deleteLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(shareLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentSecondary,
              side: BorderSide(color: AppColors.accentSecondary.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisFieldCard extends StatelessWidget {
  const _AnalysisFieldCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.accentSecondary.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accentSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Social bar (likes only) ───────────────────────────────────────────────────

class _SocialBar extends StatefulWidget {
  const _SocialBar({
    required this.dreamId,
    required this.social,
    required this.currentUserId,
  });

  final String dreamId;
  final SocialRepository social;
  final String currentUserId;

  @override
  State<_SocialBar> createState() => _SocialBarState();
}

class _SocialBarState extends State<_SocialBar> {
  bool _isLikeLoading = false;

  Future<void> _toggleLike(bool isLiked) async {
    if (widget.currentUserId.isEmpty) return;
    setState(() => _isLikeLoading = true);
    if (isLiked) {
      await widget.social.unlikeDream(
        userId: widget.currentUserId,
        dreamId: widget.dreamId,
      );
    } else {
      await widget.social.likeDream(
        userId: widget.currentUserId,
        dreamId: widget.dreamId,
      );
    }
    if (mounted) setState(() => _isLikeLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Like button
          if (widget.currentUserId.isNotEmpty)
            StreamBuilder<bool>(
              stream: widget.social.isDreamLiked(
                userId: widget.currentUserId,
                dreamId: widget.dreamId,
              ),
              builder: (_, snap) {
                final isLiked = snap.data ?? false;
                return GestureDetector(
                  onTap: _isLikeLoading ? null : () => _toggleLike(isLiked),
                  child: Row(
                    children: [
                      _isLikeLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.error,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isLiked ? Icons.favorite : Icons.favorite_outline,
                              color: isLiked
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                    ],
                  ),
                );
              },
            ),

          // Like count from likes subcollection
          const SizedBox(width: 6),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseService.firestore
                .collection('publicDreams')
                .doc(widget.dreamId)
                .collection('likes')
                .snapshots(),
            builder: (_, snap) {
              final likes = snap.data?.docs.length ?? 0;

              return Row(
                children: [
                  Text(
                    '$likes',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
