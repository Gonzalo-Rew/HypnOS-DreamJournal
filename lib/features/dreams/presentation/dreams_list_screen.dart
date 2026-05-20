import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_detail_screen.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/settings_screen.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_app_bar.dart';

class DreamsListScreen extends StatefulWidget {
  const DreamsListScreen({super.key});

  @override
  State<DreamsListScreen> createState() => _DreamsListScreenState();
}

class _DreamsListScreenState extends State<DreamsListScreen> {
  final DreamRepository _dreamRepository = DreamRepositoryImpl();

  bool _isLoading = true;
  String? _errorMessage;
  List<Dream> _dreams = const [];

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final userId = FirebaseService.getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _errorMessage = l.dreamsListNotLoggedIn;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _dreamRepository.getDreamsByUser(userId: userId);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      if (result is Success<List<Dream>>) {
        _dreams = result.value;
      } else {
        _errorMessage = (result as Failure<List<Dream>>).exception.toString();
      }
    });
  }

  Future<void> _openDetail(Dream dream) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DreamDetailScreen(dream: dream)),
    );

    if (changed == true) {
      await _loadDreams();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──
            HypnosAppBar(
              extraActions: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: _loadDreams,
                ),
              ],
              onSettingsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            // ── Body ──
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
                    );
                  }

                  if (_errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            FilledButton(
                              onPressed: _loadDreams,
                              child: Text(l.dreamsListRetry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_dreams.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_stories_outlined,
                              color: AppColors.textSecondary,
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              l.dreamsListEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadDreams,
                    color: AppColors.accentPrimary,
                    backgroundColor: AppColors.surfaceGlass,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      itemCount: _dreams.length,
                      separatorBuilder: (context2, i) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final dream = _dreams[index];
                        return RepaintBoundary(
                          child: _DreamCard(
                            dream: dream,
                            isLatest: index == 0,
                            onTap: () => _openDetail(dream),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dream card ──────────────────────────────────────────────────────────────

class _DreamCard extends StatelessWidget {
  const _DreamCard({
    required this.dream,
    required this.isLatest,
    required this.onTap,
  });

  final Dream dream;
  final bool isLatest;
  final VoidCallback onTap;

  Color _moodColor() {
    final score = dream.moodScore;
    if (score == null) return AppColors.textSecondary;
    if (score >= 4) return AppColors.success;
    if (score >= 3) return AppColors.warning;
    return AppColors.error;
  }

  String _moodLabel() {
    final score = dream.moodScore;
    if (score == null) return 'Sin valorar';
    if (score >= 4) return 'Positivo';
    if (score >= 3) return 'Neutral';
    return 'Intenso';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        accentLeft: isLatest,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Date chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSecondary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.accentSecondary.withValues(alpha: 0.40),
                    ),
                  ),
                  child: Text(
                    DateFormat('dd MMM').format(dream.dreamDate),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                // Mood pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _moodColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _moodColor(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _moodLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _moodColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              dream.title.isNotEmpty ? dream.title : 'Sin título',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: dream.title.isNotEmpty ? null : AppColors.textSecondary,
                fontStyle: dream.title.isNotEmpty ? null : FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (dream.text.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                dream.text,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
