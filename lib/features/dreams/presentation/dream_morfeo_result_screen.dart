import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_saved_step_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';

class DreamMorfeoResultScreen extends StatelessWidget {
  const DreamMorfeoResultScreen({
    super.key,
    required this.dream,
    required this.aiAnalysis,
  });

  final Dream dream;
  final Map<String, dynamic> aiAnalysis;

  String _text(String key) => (aiAnalysis[key] as String? ?? '').trim();

  List<String> _list(String key) {
    final raw = aiAnalysis[key] as List?;
    if (raw == null) return const [];
    return raw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sentiment = _text('sentiment');
    final category = _text('category');
    final summary = _text('summary');
    final psychologicalNote = _text('psychologicalNote');
    final emotions = _list('emotions');
    final characters = _list('characters');
    final places = _list('places');
    final themes = _list('themes');

    final hasAnyData =
        sentiment.isNotEmpty ||
        category.isNotEmpty ||
        summary.isNotEmpty ||
        psychologicalNote.isNotEmpty ||
        emotions.isNotEmpty ||
        characters.isNotEmpty ||
        places.isNotEmpty ||
        themes.isNotEmpty;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            l.dreamMorfeoResultTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MorfeoHeroCard(
                        subtitle: l.dreamMorfeoResultSubtitle,
                        sentiment: sentiment,
                        category: category,
                        emptyLabel: l.dreamMorfeoResultEmptyField,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (!hasAnyData)
                        _ResultWarningCard(
                          title: l.dreamAnalysisSomethingWentWrong,
                          message: l.dreamMorfeoResultEmpty,
                        ),
                      if (!hasAnyData) const SizedBox(height: AppSpacing.md),
                      _InfoCard(
                        title: l.dreamDetailAiSummary,
                        icon: Icons.auto_stories_rounded,
                        child: Text(
                          summary.isNotEmpty
                              ? summary
                              : l.dreamMorfeoResultEmptyField,
                          style: TextStyle(
                            color: summary.isNotEmpty
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 15,
                            fontStyle: summary.isNotEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _InfoCard(
                        title: l.dreamDetailAiPsychNote,
                        icon: Icons.psychology_alt_rounded,
                        child: Text(
                          psychologicalNote.isNotEmpty
                              ? psychologicalNote
                              : l.dreamMorfeoResultEmptyField,
                          style: TextStyle(
                            color: psychologicalNote.isNotEmpty
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: l.dreamDetailAiSentiment,
                              value: sentiment.isNotEmpty
                                  ? sentiment
                                  : l.dreamMorfeoResultEmptyField,
                              icon: Icons.favorite_rounded,
                              accent: AppColors.accentSecondary,
                              emptyLabel: l.dreamMorfeoResultEmptyField,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MetricCard(
                              label: l.dreamDetailAiCategory,
                              value: category.isNotEmpty
                                  ? category
                                  : l.dreamMorfeoResultEmptyField,
                              icon: Icons.grid_view_rounded,
                              accent: AppColors.accentPrimary,
                              emptyLabel: l.dreamMorfeoResultEmptyField,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ListCard(
                        title: l.dreamDetailAiEmotions,
                        icon: Icons.mood_rounded,
                        items: emotions,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ListCard(
                        title: l.dreamDetailAiCharacters,
                        icon: Icons.groups_rounded,
                        items: characters,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ListCard(
                        title: l.dreamDetailAiPlaces,
                        icon: Icons.place_rounded,
                        items: places,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ListCard(
                        title: l.dreamDetailAiThemes,
                        icon: Icons.interests_rounded,
                        items: themes,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderSubtle.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => DreamSavedStepScreen(
                          dream: dream,
                          aiAnalysis: aiAnalysis,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: AppColors.bgPrimary,
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  child: Text(l.dreamMorfeoResultContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MorfeoHeroCard extends StatelessWidget {
  const _MorfeoHeroCard({
    required this.subtitle,
    required this.sentiment,
    required this.category,
    required this.emptyLabel,
  });

  final String subtitle;
  final String sentiment;
  final String category;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentSecondary.withValues(alpha: 0.26),
            AppColors.accentSecondary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSecondary.withValues(alpha: 0.2),
            blurRadius: 28,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          const MorpheusOrb(size: 108, showBlueGlow: false),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppLocalizations.of(context).welcomeMorpheusTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _HeroPill(
                icon: Icons.favorite_rounded,
                text: sentiment.isNotEmpty ? sentiment : emptyLabel,
              ),
              _HeroPill(
                icon: Icons.grid_view_rounded,
                text: category.isNotEmpty ? category : emptyLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accentSecondary, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultWarningCard extends StatelessWidget {
  const _ResultWarningCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 17,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.accentSecondary),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.emptyLabel,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != emptyLabel;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.38), width: 1),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: hasValue ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentSecondary, size: 15),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.05,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            Text(
              l.dreamMorfeoResultEmptyField,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in items)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accentSecondary.withValues(alpha: 0.24),
                          AppColors.accentPrimary.withValues(alpha: 0.14),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.accentSecondary.withValues(
                          alpha: 0.38,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
