import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hypnos_dreamjournal/app/main_shell.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';

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
  String _profileDreamVisibility = 'public';
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
                      const Text(
                        'Morfeo no pudo analizar el sueño',
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
            doc.data()?['dreamVisibility'] as String? ?? 'public';
      });
    } catch (_) {}
  }

  DreamVisibility get _resolvedVisibility {
    if (!_isPublished) return DreamVisibility.private;
    return switch (_profileDreamVisibility) {
      'public' => DreamVisibility.public,
      'followers' => DreamVisibility.followers,
      _ => DreamVisibility.private,
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
    final title = widget.dream.title;
    final body = widget.dream.text.trim();
    final shareText = body.isNotEmpty
        ? '✨ "$title"\n\n$body\n\n— Registrado en Hypnos Dream Journal'
        : '✨ "$title"\n\n— Registrado en Hypnos Dream Journal';
    Share.share(shareText, subject: title);
  }

  /// Navigate back to the diary tab.
  void _goToJournal() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    MainShell.switchToTab(1); // diary tab index
  }

  @override
  Widget build(BuildContext context) {
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
                    AppSpacing.lg,
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
                            const SizedBox(height: AppSpacing.md),
                            const Text(
                              '¡Sueño guardado!',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.dream.title.isNotEmpty
                                  ? widget.dream.title
                                  : 'Sin título',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
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
                      _GlassCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.public_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Publicar sueño',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isPublished
                                        ? _visibilityLabel()
                                        : 'Solo visible para ti',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isSavingPublish)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentPrimary,
                                ),
                              )
                            else
                              Switch(
                                value: _isPublished,
                                onChanged: _togglePublish,
                                activeColor: AppColors.accentPrimary,
                                activeTrackColor: AppColors.accentPrimary
                                    .withValues(alpha: 0.3),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Share section ──────────────────────────────
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'COMPARTIR',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _ShareTile(
                                    icon: Icons.chat_rounded,
                                    label: 'WhatsApp',
                                    color: const Color(0xFF25D366),
                                    onTap: _shareViaSheet,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: _ShareTile(
                                    icon: Icons.share_rounded,
                                    label: 'Más',
                                    color: AppColors.accentPrimary,
                                    onTap: _shareViaSheet,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                    child: const Text(
                      'Ir al diario',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
    'public' => 'Visible para todos',
    'followers' => 'Visible para seguidores',
    _ => 'Solo visible para ti',
  };
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SuccessOrb extends StatelessWidget {
  const _SuccessOrb({this.hasAnalysis = false});
  final bool hasAnalysis;

  @override
  Widget build(BuildContext context) {
    final color = hasAnalysis
        ? AppColors.accentSecondary
        : AppColors.accentPrimary;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        hasAnalysis ? Icons.auto_awesome_rounded : Icons.check_rounded,
        color: color,
        size: 32,
      ),
    );
  }
}

// ── Morfeo analysis card ─────────────────────────────────────────────────────

class _MorfeoAnalysisCard extends StatelessWidget {
  const _MorfeoAnalysisCard({required this.analysis});
  final Map<String, dynamic> analysis;

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'INTERPRETACIÓN DE MORFEO',
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
            const Text(
              'EMOCIONES',
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
            const Text(
              'TEMAS',
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

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: child,
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
