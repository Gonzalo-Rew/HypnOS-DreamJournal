import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_detail_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dreams_list_screen.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/settings_screen.dart';
import 'package:hypnos_dreamjournal/features/social/presentation/user_search_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_app_bar.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DreamRepository _repo = DreamRepositoryImpl();
  List<Dream> _recentDreams = [];
  bool _isLoading = true;

  Dream? get _lastDream =>
      _recentDreams.isNotEmpty ? _recentDreams.first : null;
  List<Dream> get _otherDreams =>
      _recentDreams.length > 1 ? _recentDreams.sublist(1) : [];

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final uid = FirebaseService.getCurrentUserId();
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final result = await _repo.getDreamsByUser(userId: uid, limit: 6);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result is Success<List<Dream>>) {
        _recentDreams = result.value;
      }
    });
  }

  Future<void> _openDetail(Dream dream) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DreamDetailScreen(dream: dream)),
    );
    _loadDreams();
  }

  void _openAllDreams() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DreamsListScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            HypnosAppBar(
              onSettingsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              extraActions: [
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserSearchScreen()),
                  ),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadDreams,
                color: AppColors.accentPrimary,
                backgroundColor: AppColors.surfaceGlass,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  children: [
                    // 1. Orb + new dream CTA
                    const _HeroOrbCard(),
                    const SizedBox(height: AppSpacing.lg),

                    // 2. Last dream featured card
                    if (_isLoading)
                      const _LoadingCard()
                    else if (_lastDream != null)
                      RepaintBoundary(
                        child: _LastDreamFeaturedCard(
                          dream: _lastDream!,
                          onTap: () => _openDetail(_lastDream!),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // 3. Recent dreams horizontal scroll
                    if (!_isLoading && _otherDreams.isNotEmpty) ...[
                      _RecentDreamsHeader(onViewAll: _openAllDreams),
                      const SizedBox(height: AppSpacing.sm),
                      _RecentDreamsRow(
                        dreams: _otherDreams,
                        onTap: _openDetail,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Orb + CTA hero card (compact) ---

class _HeroOrbCard extends StatelessWidget {
  const _HeroOrbCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassCard(
      radius: AppRadius.lg,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          const MorpheusOrb(size: 80),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Morfeo te escucha',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Registra lo que has soñado antes de que se desvanezca.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
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

// --- Last dream featured card ---

class _LastDreamFeaturedCard extends StatelessWidget {
  const _LastDreamFeaturedCard({required this.dream, required this.onTap});

  final Dream dream;
  final VoidCallback onTap;

  String _emotionLabel() {
    final score = dream.moodScore;
    if (score == null) return 'Sin valorar';
    if (score >= 5) return 'Intenso';
    if (score >= 4) return 'Positivo';
    if (score >= 3) return 'Neutral';
    if (score >= 2) return 'Inquieto';
    return 'Oscuro';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0D1B2A),
                AppColors.accentSecondary.withValues(alpha: 0.25),
                const Color(0xFF0A0C14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: emotion chip + "Anoche"
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSecondary.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.accentSecondary.withValues(
                          alpha: 0.60,
                        ),
                      ),
                    ),
                    child: Text(
                      _emotionLabel(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Anoche',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Title
              Text(
                dream.title.isNotEmpty ? dream.title : 'Sin título',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: dream.title.isNotEmpty
                      ? AppColors.accentPrimary
                      : AppColors.textSecondary,
                  fontStyle: dream.title.isNotEmpty ? null : FontStyle.italic,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Excerpt
              Text(
                dream.text.length > 100
                    ? '${dream.text.substring(0, 100)}...'
                    : dream.text,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              // CTA
              Row(
                children: [
                  Text(
                    'CONTINUAR LEYENDO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.accentPrimary,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Recent dreams header ---

class _RecentDreamsHeader extends StatelessWidget {
  const _RecentDreamsHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Sueños recientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'VER TODOS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accentPrimary,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Recent dreams horizontal row ---

class _RecentDreamsRow extends StatelessWidget {
  const _RecentDreamsRow({required this.dreams, required this.onTap});

  final List<Dream> dreams;
  final void Function(Dream) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dreams.length,
        separatorBuilder: (context2, i2) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          return _RecentDreamCard(
            dream: dreams[i],
            onTap: () => onTap(dreams[i]),
          );
        },
      ),
    );
  }
}

class _RecentDreamCard extends StatelessWidget {
  const _RecentDreamCard({required this.dream, required this.onTap});

  final Dream dream;
  final VoidCallback onTap;

  Color _moodColor() {
    final score = dream.moodScore;
    if (score == null) return AppColors.textSecondary;
    if (score >= 4) return AppColors.success;
    if (score >= 3) return AppColors.warning;
    return AppColors.error;
  }

  String _tagLabel() {
    if (dream.tags.isNotEmpty) return dream.tags.first.toUpperCase();
    final score = dream.moodScore;
    if (score == null) return 'SIN TAG';
    if (score >= 5) return 'INTENSO';
    if (score >= 4) return 'LUCIDO';
    if (score >= 3) return 'NORMAL';
    return 'OSCURO';
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d').format(dream.dreamDate).toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: LinearGradient(
            colors: [
              AppColors.accentSecondary.withValues(alpha: 0.20),
              const Color(0xFF0D1B2A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top spacer (mimics image area)
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.nights_stay_outlined,
                    color: AppColors.accentPrimary.withValues(alpha: 0.30),
                    size: 36,
                  ),
                ),
              ),
              // Date
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              // Title
              Text(
                dream.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Tag chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _moodColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _moodColor().withValues(alpha: 0.40),
                  ),
                ),
                child: Text(
                  _tagLabel(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _moodColor(),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Loading placeholder ---

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 180,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.accentPrimary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
