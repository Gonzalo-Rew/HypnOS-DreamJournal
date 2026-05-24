import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hypnos_dreamjournal/app/main_shell.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dreams_refresh_bus.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/account_security_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';

// ── Step 3 of the dream creation wizard ────────────────────────────────────
// Dream was just saved. User can publish it and/or share it.

class DreamSavedStepScreen extends StatefulWidget {
  const DreamSavedStepScreen({
    super.key,
    required this.dream,
    this.aiAnalysis,
    this.morfeoError,
  });

  final Dream dream;

  /// Analysis map passed directly from the wizard so it is available
  /// immediately without a Firestore round-trip.
  final Map<String, dynamic>? aiAnalysis;

  /// Non-null when Morfeo analysis failed (but dream was still saved).
  final String? morfeoError;

  @override
  State<DreamSavedStepScreen> createState() => _DreamSavedStepScreenState();
}

class _DreamSavedStepScreenState extends State<DreamSavedStepScreen> {
  late bool _isPublished;
  String _profileDreamVisibility = 'followers';
  bool _isSavingPublish = false;

  Map<String, dynamic>? get _analysis =>
      widget.aiAnalysis ?? widget.dream.aiAnalysis;

  @override
  void initState() {
    super.initState();
    _isPublished = widget.dream.isPublished;
    _loadProfileVisibility();
    if (widget.morfeoError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2D1B1B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE57373), width: 1),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 6),
            content: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE57373),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).dreamSavedMorfeoAnalyzeFailedTitle,
                        style: TextStyle(
                          color: Color(0xFFEF9A9A),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        widget.morfeoError!,
                        style: const TextStyle(
                          color: Color(0xFFBCAAA4),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  Future<void> _loadProfileVisibility() async {
    final userId = FirebaseService.getCurrentUserId();
    if (userId == null) return;
    try {
      final doc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();
      if (!mounted) return;
      setState(() {
        _profileDreamVisibility =
            (doc.data()?['dreamVisibility'] as String?) == 'public'
            ? 'public'
            : 'followers';
      });
    } catch (_) {}
  }

  DreamVisibility get _resolvedVisibility {
    if (!_isPublished) return DreamVisibility.private;
    return switch (_profileDreamVisibility) {
      'public' => DreamVisibility.public,
      'followers' => DreamVisibility.followers,
      _ => DreamVisibility.followers,
    };
  }

  Future<void> _togglePublish(bool value) async {
    setState(() {
      _isPublished = value;
      _isSavingPublish = true;
    });

    final userId = FirebaseService.getCurrentUserId();
    if (userId != null) {
      await DreamRepositoryImpl().updateDream(
        userId: userId,
        dreamId: widget.dream.id,
        data: {'isPublished': value, 'visibility': _resolvedVisibility.name},
      );
    }

    if (mounted) setState(() => _isSavingPublish = false);
  }

  void _shareViaSheet() {
    final l = AppLocalizations.of(context);
    final title = widget.dream.title;
    final body = widget.dream.text.trim();
    final shareText = body.isNotEmpty
        ? l.dreamSavedShareWithBody(title, body)
        : l.dreamSavedShareWithoutBody(title);
    Share.share(shareText, subject: title);
  }

  /// Navigate back to the diary tab.
  void _goToJournal() {
    DreamsRefreshBus.notifyUpdated();
    Navigator.of(context).popUntil((route) => route.isFirst);
    MainShell.switchToTab(1); // diary tab index
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      // Prevent swiping back to the analysis step
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToJournal();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Scrollable content ───────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Success header ─────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            _SuccessOrb(hasAnalysis: _analysis != null),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              l.dreamSavedTitle,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.dream.title.isNotEmpty
                                  ? widget.dream.title
                                  : l.dreamsListUntitled,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // ── Morfeo analysis ────────────────────────────
                      if (_analysis != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _MorfeoAnalysisCard(analysis: _analysis!),
                      ],

                      const SizedBox(height: AppSpacing.lg),

                      // ── Publish toggle ─────────────────────────────
                      _PublishVisibilityCard(
                        title: l.dreamSavedPublishDream,
                        subtitle: _isPublished
                            ? _visibilityLabel()
                            : l.dreamSavedVisibleOnlyYou,
                        isPublished: _isPublished,
                        isSaving: _isSavingPublish,
                        onToggle: _togglePublish,
                        onGoToSettings: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AccountSecurityScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Share section ──────────────────────────────
                      _ShareWorldSection(
                        title: l.dreamSavedShareSection,
                        moreLabel: l.dreamSavedShareMore,
                        onShare: _shareViaSheet,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),

              // ── CTA — always pinned at bottom ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPrimary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FilledButton(
                    onPressed: _goToJournal,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.bgPrimary,
                      minimumSize: const Size.fromHeight(54),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      l.dreamSavedGoToJournal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _visibilityLabel() => switch (_profileDreamVisibility) {
    'public' => AppLocalizations.of(context).dreamSavedVisibleForEveryone,
    'followers' => AppLocalizations.of(context).dreamSavedVisibleForFollowers,
    _ => AppLocalizations.of(context).dreamSavedVisibleForFollowers,
  };
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SuccessOrb extends StatelessWidget {
  const _SuccessOrb({this.hasAnalysis = false});
  final bool hasAnalysis;

  @override
  Widget build(BuildContext context) {
    final badgeColor = hasAnalysis
        ? AppColors.accentSecondary
        : AppColors.accentPrimary;
    return Stack(
      alignment: Alignment.center,
      children: [
        const MorpheusOrb(size: 124),
        Positioned(
          right: 10,
          bottom: 8,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeColor,
              border: Border.all(color: AppColors.bgPrimary, width: 2),
            ),
            child: Icon(
              hasAnalysis ? Icons.auto_awesome_rounded : Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Morfeo analysis card ─────────────────────────────────────────────────────

class _MorfeoAnalysisCard extends StatelessWidget {
  const _MorfeoAnalysisCard({required this.analysis});
  final Map<String, dynamic> analysis;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final category = analysis['category'] as String? ?? '';
    final summary = analysis['summary'] as String? ?? '';
    final emotions =
        (analysis['emotions'] as List?)?.map((e) => e.toString()).toList() ??
        [];
    final themes =
        (analysis['themes'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final psychNote = analysis['psychologicalNote'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accentSecondary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                l.dreamSavedMorfeoInterpretation,
                style: TextStyle(
                  color: AppColors.accentSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              if (category.isNotEmpty) ...[
                const Spacer(),
                _CategoryBadge(category),
              ],
            ],
          ),
          // Summary
          if (summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              summary,
              style: const TextStyle(
                fontFamily: 'Lora',
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          // Emotions
          if (emotions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.dreamDetailAiEmotions.toUpperCase(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in emotions)
                  _Chip(label: e, color: const Color(0xFF9B59B6)),
              ],
            ),
          ],
          // Themes
          if (themes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.dreamDetailAiThemes.toUpperCase(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in themes)
                  _Chip(label: t, color: AppColors.accentPrimary),
              ],
            ),
          ],
          // Psychological note
          if (psychNote.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentSecondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.accentSecondary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                psychNote,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accentSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PublishVisibilityCard extends StatelessWidget {
  const _PublishVisibilityCard({
    required this.title,
    required this.subtitle,
    required this.isPublished,
    required this.isSaving,
    required this.onToggle,
    required this.onGoToSettings,
  });

  final String title;
  final String subtitle;
  final bool isPublished;
  final bool isSaving;
  final ValueChanged<bool> onToggle;
  final VoidCallback onGoToSettings;

  @override
  Widget build(BuildContext context) {
    final audienceLabel = isPublished ? 'Publicado' : 'Pendiente de publicar';
    final audienceIcon = isPublished
        ? Icons.public
        : Icons.visibility_off_outlined;

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
          color: AppColors.borderSubtle.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.bgPrimary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  audienceIcon,
                  color: AppColors.accentPrimary,
                  size: 22,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        audienceLabel,
                        style: const TextStyle(
                          color: AppColors.accentPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isSaving)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentPrimary,
                  ),
                )
              else
                Transform.scale(
                  scale: 0.95,
                  child: Switch(
                    value: isPublished,
                    onChanged: onToggle,
                    activeThumbColor: AppColors.bgPrimary,
                    activeTrackColor: AppColors.accentPrimary,
                    inactiveThumbColor: const Color(0xFFCFD8DC),
                    inactiveTrackColor: const Color(0xFF2A2D3A),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.65),
              ),
            ),
            child: Text(
              isPublished
                  ? 'Revisa la audiencia desde Ajustes si quieres cambiarla.'
                  : 'Al publicarlo, saldrá con la audiencia configurada en Ajustes.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onGoToSettings,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Text(
                'Cambiar en Ajustes ->',
                style: const TextStyle(
                  color: AppColors.accentPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareWorldSection extends StatelessWidget {
  const _ShareWorldSection({
    required this.title,
    required this.moreLabel,
    required this.onShare,
  });

  final String title;
  final String moreLabel;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ShareTile(
          icon: Icons.share_rounded,
          label: moreLabel,
          color: AppColors.accentPrimary,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
