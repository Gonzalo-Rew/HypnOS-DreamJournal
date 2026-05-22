import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_detail_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dreams_refresh_bus.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/settings_screen.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/utils/intensity_utils.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_app_bar.dart';

class DreamsListScreen extends StatefulWidget {
  const DreamsListScreen({super.key});

  @override
  State<DreamsListScreen> createState() => _DreamsListScreenState();
}

class _DreamsListScreenState extends State<DreamsListScreen> {
  final DreamRepository _dreamRepository = DreamRepositoryImpl();
  late final VoidCallback _refreshBusListener;

  bool _isLoading = true;
  String? _errorMessage;
  List<Dream> _dreams = const [];

  // ── Filtro por fecha ──────────────────────────────────────────────────────
  DateTime? _filterFrom;
  DateTime? _filterTo;

  List<Dream> get _filteredDreams {
    if (_filterFrom == null && _filterTo == null) return _dreams;
    return _dreams.where((d) {
      final date = DateTime(
        d.dreamDate.year,
        d.dreamDate.month,
        d.dreamDate.day,
      );
      if (_filterFrom != null && date.isBefore(_filterFrom!)) return false;
      if (_filterTo != null && date.isAfter(_filterTo!)) return false;
      return true;
    }).toList();
  }

  bool get _isFiltering => _filterFrom != null || _filterTo != null;

  @override
  void initState() {
    super.initState();
    _refreshBusListener = () {
      if (!mounted) return;
      _loadDreams();
    };
    DreamsRefreshBus.listenable.addListener(_refreshBusListener);
    _loadDreams();
  }

  @override
  void dispose() {
    DreamsRefreshBus.listenable.removeListener(_refreshBusListener);
    super.dispose();
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

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result is Success<List<Dream>>) {
        _dreams = result.value;
      } else {
        _errorMessage = (result as Failure<List<Dream>>).exception.toString();
      }
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _filterFrom != null && _filterTo != null
          ? DateTimeRange(start: _filterFrom!, end: _filterTo!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accentPrimary,
            onPrimary: AppColors.bgPrimary,
            surface: const Color(0xFF181B2A),
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF181B2A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _filterFrom = DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
        );
        _filterTo = DateTime(picked.end.year, picked.end.month, picked.end.day);
      });
    }
  }

  void _clearFilter() => setState(() {
    _filterFrom = null;
    _filterTo = null;
  });

  Future<void> _openDetail(Dream dream) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DreamDetailScreen(dream: dream)),
    );
    if (changed == true) await _loadDreams();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final filtered = _filteredDreams;

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

            // ── Barra de filtro por fecha ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: GestureDetector(
                onTap: _pickDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isFiltering
                        ? AppColors.accentPrimary.withValues(alpha: 0.12)
                        : AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: _isFiltering
                          ? AppColors.accentPrimary.withValues(alpha: 0.50)
                          : AppColors.borderSubtle.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        size: 16,
                        color: _isFiltering
                            ? AppColors.accentPrimary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isFiltering
                              ? '${DateFormat('dd MMM yyyy', localeCode).format(_filterFrom!)}  ->  ${DateFormat('dd MMM yyyy', localeCode).format(_filterTo!)}'
                              : l.dreamsListFilterByDate,
                          style: TextStyle(
                            color: _isFiltering
                                ? AppColors.accentPrimary
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: _isFiltering
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (_isFiltering)
                        GestureDetector(
                          onTap: _clearFilter,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.accentPrimary,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Etiqueta de resultados cuando filtra ──────────────────────
            if (_isFiltering && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Text(
                      l.dreamsListResults(filtered.length),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Body ──────────────────────────────────────────────────────
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

                  if (filtered.isEmpty) {
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
                              _isFiltering
                                  ? l.dreamsListNoDreamsInRange
                                  : l.dreamsListEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (_isFiltering) ...[
                              const SizedBox(height: AppSpacing.sm),
                              TextButton.icon(
                                onPressed: _clearFilter,
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.accentPrimary,
                                ),
                                label: Text(
                                  l.dreamsListClearFilter,
                                  style: TextStyle(
                                    color: AppColors.accentPrimary,
                                  ),
                                ),
                              ),
                            ],
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
                      itemCount: filtered.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final dream = filtered[index];
                        return RepaintBoundary(
                          child: _DreamCard(
                            dream: dream,
                            isLatest: index == 0 && !_isFiltering,
                            l: l,
                            localeCode: localeCode,
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
    required this.l,
    required this.localeCode,
    required this.onTap,
  });

  final Dream dream;
  final bool isLatest;
  final AppLocalizations l;
  final String localeCode;
  final VoidCallback onTap;

  Color _moodColor() {
    return IntensityUtils.color(dream.moodScore);
  }

  String _moodLabel() {
    return IntensityUtils.label(l, dream.moodScore);
  }

  bool _isAnalyzed() {
    final hasStructured =
        dream.aiAnalysis != null && dream.aiAnalysis!.isNotEmpty;
    final hasByLanguage =
        dream.aiAnalysisByLanguage != null &&
        dream.aiAnalysisByLanguage!.isNotEmpty;
    final hasSummary = dream.aiSummary?.trim().isNotEmpty ?? false;
    return hasStructured || hasByLanguage || hasSummary;
  }

  @override
  Widget build(BuildContext context) {
    final analyzed = _isAnalyzed();
    final assistantName = AppLocalizations.of(context).welcomeMorpheusTitle;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        accentLeft: isLatest,
        borderColor: analyzed
            ? AppColors.accentSecondary.withValues(alpha: 0.45)
            : null,
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
                    DateFormat('dd MMM', localeCode).format(dream.dreamDate),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                if (analyzed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSecondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.accentSecondary.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: Text(
                      assistantName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentSecondary,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
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
              dream.title.isNotEmpty ? dream.title : l.dreamsListUntitled,
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
