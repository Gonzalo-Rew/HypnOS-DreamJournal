import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/app/theme/app_text_styles.dart';
import 'package:hypnos_dreamjournal/core/config/app_settings.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/gemini_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/audio_player_widget.dart';
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

  // Sprint 4: AI enabled toggle
  bool _aiEnabled = true;

  @override
  void initState() {
    super.initState();
    _dream = widget.dream;
    _loadAiEnabled();
  }

  Future<void> _loadAiEnabled() async {
    final enabled = await AppSettings.instance.getAiEnabled();
    if (mounted) setState(() => _aiEnabled = enabled);
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
        _errorMessage = (result as Failure<Dream>).exception.toString();
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
      builder: (ctx) {
        final dl = AppLocalizations.of(ctx);
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2230),
          surfaceTintColor: Colors.transparent,
          title: Text(dl.dreamDetailDeleteDialogTitle),
          content: Text(dl.dreamDetailDeleteDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dl.dreamDetailDeleteCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(dl.dreamDetailDeleteConfirm),
            ),
          ],
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
      _errorMessage = (result as Failure<void>).exception.toString();
    });
  }

  Future<void> _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    final apiKey = await AppSettings.instance.getGeminiApiKey();
    if (!mounted) return;

    if (apiKey == null) {
      setState(() {
        _isAnalyzing = false;
        _analysisError =
            AppLocalizations.of(context).dreamDetailAnalysisNoKey;
      });
      return;
    }

    GeminiService.instance.initialize(apiKey);

    final result = await GeminiService.instance.analyzeDream(
      title: _dream.title,
      text: _dream.text,
      moodScore: _dream.moodScore,
      contextNotes: _dream.contextNotes,
    );

    if (!mounted) return;

    if (result is Success<DreamAnalysis>) {
      final analysis = result.value;
      // Persist aiCategory and aiSummary back to Firestore
      _dreamRepository.updateDream(
        userId: _dream.userId,
        dreamId: _dream.id,
        data: {
          'aiCategory': analysis.category,
          'aiSummary': analysis.summary,
          'transcription': _dream.transcription,
          'aiAnalysisData': analysis.toMap(),
        },
      );
      setState(() {
        _analysis = analysis;
        _isAnalyzing = false;
        _dream = _dream.copyWith(
          aiCategory: analysis.category,
          aiSummary: analysis.summary,
        );
      });
    } else {
      final failure = result as Failure<DreamAnalysis>;
      setState(() {
        _isAnalyzing = false;
        _analysisError = failure.exception.toString();
      });
    }
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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(DateFormat.yMMMd().add_jm().format(_dream.dreamDate)),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  _dream.text.isNotEmpty ? _dream.text : '-',
                  style: AppTextStyles.dreamBody,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Text(l.dreamDetailMoodScore),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: l.dreamDetailMoodTooltip,
                          triggerMode: TooltipTriggerMode.tap,
                          child: const Icon(Icons.info_outline, size: 16),
                        ),
                      ],
                    ),
                    subtitle: Text((_dream.moodScore ?? 3).toString()),
                  ),
                  ListTile(
                    title: Text(l.dreamDetailContextNotes),
                    subtitle: Text(
                      _dream.contextNotes?.isNotEmpty == true
                          ? _dream.contextNotes!
                          : '-',
                    ),
                  ),
                  ListTile(
                    title: Text(l.dreamDetailAiCategory),
                    subtitle: Text(
                      _dream.aiCategory ?? l.dreamDetailAiCategoryPending,
                    ),
                  ),
                ],
              ),
            ),
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
                analysis: _analysis,
                aiSummary: _dream.aiSummary,
                isAnalyzing: _isAnalyzing,
                analysisError: _analysisError,
                onRunAnalysis: _runAnalysis,
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
                    const Icon(Icons.auto_awesome_outlined, color: Colors.grey, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      AppLocalizations.of(context).profileAiEnabledHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            // ─────────────────────────────────────────────────────────────
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _isDeleting ? null : _editDream,
              icon: const Icon(Icons.edit),
              label: Text(l.dreamDetailEditButton),
            ),
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton.icon(
              onPressed: _isDeleting ? null : _deleteDream,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              label: Text(l.dreamDetailDeleteButton),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.accentPrimary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l.dreamDetailAiAnalysis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          if (analysisError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              analysisError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ],
          if (analysis != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _AnalysisRow(label: l.dreamDetailAiSentiment, value: analysis!.sentiment),
            if (analysis!.emotions.isNotEmpty)
              _AnalysisRow(
                label: l.dreamDetailAiEmotions,
                value: analysis!.emotions.join(', '),
              ),
            if (analysis!.characters.isNotEmpty)
              _AnalysisRow(
                label: l.dreamDetailAiCharacters,
                value: analysis!.characters.join(', '),
              ),
            if (analysis!.places.isNotEmpty)
              _AnalysisRow(
                label: l.dreamDetailAiPlaces,
                value: analysis!.places.join(', '),
              ),
            if (analysis!.themes.isNotEmpty)
              _AnalysisRow(
                label: l.dreamDetailAiThemes,
                value: analysis!.themes.join(', '),
              ),
            if (analysis!.psychologicalNote.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.dreamDetailAiPsychNote,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.accentSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                analysis!.psychologicalNote,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ] else if (aiSummary != null && aiSummary!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              aiSummary!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: isAnalyzing ? null : onRunAnalysis,
            icon: isAnalyzing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentPrimary,
                    ),
                  )
                : const Icon(Icons.auto_awesome, size: 16),
            label: Text(isAnalyzing ? l.dreamDetailAnalyzing : l.dreamDetailAnalyzeButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentPrimary,
              side: const BorderSide(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
