import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dashboard/presentation/dashboard_refresh_bus.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/settings_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/errors/error_messages.dart';
import 'package:hypnos_dreamjournal/shared/utils/intensity_utils.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_app_bar.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DreamRepository _dreamRepository = DreamRepositoryImpl();
  static const String _notLoggedInErrorCode = 'dashboard_not_logged_in';
  late final VoidCallback _refreshBusListener;
  _IntensityRange _intensityRange = _IntensityRange.week;

  bool _isLoading = true;
  String? _errorMessage;
  List<Dream> _dreams = [];

  @override
  void initState() {
    super.initState();
    _refreshBusListener = () {
      if (!mounted) return;
      _loadDreams();
    };
    DashboardRefreshBus.listenable.addListener(_refreshBusListener);
    _loadDreams();
  }

  @override
  void dispose() {
    DashboardRefreshBus.listenable.removeListener(_refreshBusListener);
    super.dispose();
  }

  Future<void> _loadDreams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final uid = FirebaseService.getCurrentUser()?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = _notLoggedInErrorCode;
      });
      return;
    }

    try {
      final result = await _dreamRepository.getDreamsByUser(
        userId: uid,
        limit: 200,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (result is Success<List<Dream>>) {
          _dreams = result.value;
          _dreams.sort((a, b) => a.dreamDate.compareTo(b.dreamDate));
        } else {
          _errorMessage = AppError.handle(
            (result as Failure<List<Dream>>).exception,
            'Dashboard.load',
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = AppError.handle(
          Exception(e.toString()),
          'Dashboard.load.unexpected',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final metrics = _DashboardMetrics.fromDreams(_dreams);
    final resolvedErrorMessage = _errorMessage == _notLoggedInErrorCode
        ? l.dashboardNotLoggedIn
        : _errorMessage;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            HypnosAppBar(
              extraActions: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh_outlined,
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
            // Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
                    )
                  : resolvedErrorMessage != null
                  ? Center(child: Text(resolvedErrorMessage))
                  : _dreams.isEmpty
                  ? _EmptyState(l: l)
                  : RefreshIndicator(
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
                          _MorpheusPanel(dreams: _dreams),
                          const SizedBox(height: AppSpacing.md),
                          _SummaryCard(metrics: metrics),
                          const SizedBox(height: AppSpacing.md),
                          _MoodChartCard(
                            dreams: _dreams,
                            range: _intensityRange,
                            onRangeChanged: (range) {
                              setState(() {
                                _intensityRange = range;
                              });
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _DreamsPerWeekCard(dreams: _dreams),
                          const SizedBox(height: AppSpacing.md),
                          _TopCategoriesCard(metrics: metrics),
                          const SizedBox(height: AppSpacing.md),
                          _RecurringElementsCard(metrics: metrics),
                          const SizedBox(height: AppSpacing.md),
                          _CorrelationCard(dreams: _dreams),
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

class _DashboardMetrics {
  final int totalDreams;
  final int dreamsThisMonth;
  final double? averageMood;
  final int aiAnalyzed;
  final List<Dream> moodSeries7d;
  final List<_WeekCount> weekCounts;
  final List<MapEntry<String, int>> topCategories;
  final List<MapEntry<String, int>> topTags;

  const _DashboardMetrics({
    required this.totalDreams,
    required this.dreamsThisMonth,
    required this.averageMood,
    required this.aiAnalyzed,
    required this.moodSeries7d,
    required this.weekCounts,
    required this.topCategories,
    required this.topTags,
  });

  factory _DashboardMetrics.fromDreams(List<Dream> dreams) {
    final now = DateTime.now();
    final withMood = dreams.where((d) => d.moodScore != null).toList();
    final avgMood = withMood.isEmpty
        ? null
        : withMood.map((d) => d.moodScore!).reduce((a, b) => a + b) /
              withMood.length;

    final monthCount = dreams
        .where(
          (d) => d.dreamDate.year == now.year && d.dreamDate.month == now.month,
        )
        .length;

    final aiAnalyzed = dreams.where(_hasAiSignal).length;

    final moodSeries7d = withMood.length > 7
        ? withMood.sublist(withMood.length - 7)
        : withMood;

    final weekCounts = _buildLastSixWeeks(dreams, now);
    final topCategories = _buildTopCategories(dreams);
    final topTags = _buildTopTags(dreams);

    return _DashboardMetrics(
      totalDreams: dreams.length,
      dreamsThisMonth: monthCount,
      averageMood: avgMood,
      aiAnalyzed: aiAnalyzed,
      moodSeries7d: moodSeries7d,
      weekCounts: weekCounts,
      topCategories: topCategories,
      topTags: topTags,
    );
  }

  static bool _hasAiSignal(Dream d) {
    final hasCategory = d.aiCategory?.trim().isNotEmpty ?? false;
    final hasAnalysis = d.aiAnalysis != null && d.aiAnalysis!.isNotEmpty;
    final hasAnalysisByLanguage =
        d.aiAnalysisByLanguage != null && d.aiAnalysisByLanguage!.isNotEmpty;
    return hasCategory || hasAnalysis || hasAnalysisByLanguage;
  }

  static DateTime _startOfWeek(DateTime date) {
    final midnight = DateTime(date.year, date.month, date.day);
    return midnight.subtract(
      Duration(days: midnight.weekday - DateTime.monday),
    );
  }

  static List<_WeekCount> _buildLastSixWeeks(List<Dream> dreams, DateTime now) {
    final startCurrentWeek = _startOfWeek(now);
    final weeks = <_WeekCount>[];

    for (int i = 5; i >= 0; i--) {
      final weekStart = startCurrentWeek.subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final count = dreams
          .where(
            (d) =>
                !d.dreamDate.isBefore(weekStart) &&
                d.dreamDate.isBefore(weekEnd),
          )
          .length;
      weeks.add(_WeekCount(start: weekStart, count: count));
    }

    return weeks;
  }

  static List<MapEntry<String, int>> _buildTopCategories(List<Dream> dreams) {
    final freq = <String, int>{};
    for (final d in dreams) {
      final normalized = _normalizeLabel(d.aiCategory);
      if (normalized.isNotEmpty) {
        freq[normalized] = (freq[normalized] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(6).toList();
  }

  static List<MapEntry<String, int>> _buildTopTags(List<Dream> dreams) {
    final freq = <String, int>{};
    for (final d in dreams) {
      for (final tag in d.tags) {
        if (_isIntensityTag(tag)) {
          continue;
        }
        final normalized = _normalizeLabel(tag);
        if (normalized.isNotEmpty) {
          freq[normalized] = (freq[normalized] ?? 0) + 1;
        }
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(8).toList();
  }

  static String _normalizeLabel(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return '';
    final words = clean
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return words
        .map(
          (w) => w.length == 1
              ? w.toUpperCase()
              : '${w[0].toUpperCase()}${w.substring(1)}',
        )
        .join(' ');
  }

  static bool _isIntensityTag(String value) {
    final normalized = value.trim().toLowerCase();
    return RegExp(r'^mood:\s*[1-5]$').hasMatch(normalized);
  }
}

class _WeekCount {
  final DateTime start;
  final int count;

  const _WeekCount({required this.start, required this.count});
}

enum _IntensityRange { week, month }

String _localizeEntityLabel(String raw, {required bool isSpanish}) {
  final key = _entityCanonicalKey(raw);
  if (key == null) {
    return raw;
  }

  const es = <String, String>{
    'anxiety': 'Ansiedad',
    'nightmare': 'Pesadilla',
    'fantasy': 'Fantasía',
    'surreal': 'Surreal',
    'neutral': 'Neutral',
    'water': 'Agua',
    'flooding': 'Inundación',
    'pursuit': 'Persecución',
    'threat': 'Amenaza',
    'fall': 'Caída',
    'loss_control': 'Pérdida de control',
    'flight': 'Vuelo',
    'freedom': 'Libertad',
    'stress': 'Estres',
    'fear': 'Miedo',
    'teeth': 'Dientes',
    'exam': 'Examen',
    'train': 'Tren',
    'forest': 'Bosque',
    'house': 'Casa',
  };

  const en = <String, String>{
    'anxiety': 'Anxiety',
    'nightmare': 'Nightmare',
    'fantasy': 'Fantasy',
    'surreal': 'Surreal',
    'neutral': 'Neutral',
    'water': 'Water',
    'flooding': 'Flooding',
    'pursuit': 'Pursuit',
    'threat': 'Threat',
    'fall': 'Fall',
    'loss_control': 'Loss of Control',
    'flight': 'Flight',
    'freedom': 'Freedom',
    'stress': 'Stress',
    'fear': 'Fear',
    'teeth': 'Teeth',
    'exam': 'Exam',
    'train': 'Train',
    'forest': 'Forest',
    'house': 'House',
  };

  return (isSpanish ? es : en)[key] ?? raw;
}

String? _entityCanonicalKey(String raw) {
  final normalized = _normalizeEntityText(raw)
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (normalized.isEmpty) return null;

  const dictionary = <String, String>{
    'ansiedad': 'anxiety',
    'anxiety': 'anxiety',
    'pesadilla': 'nightmare',
    'nightmare': 'nightmare',
    'fantasia': 'fantasy',
    'fantasy': 'fantasy',
    'surreal': 'surreal',
    'neutral': 'neutral',
    'agua': 'water',
    'water': 'water',
    'inundacion': 'flooding',
    'flooding': 'flooding',
    'persecucion': 'pursuit',
    'pursuit': 'pursuit',
    'amenaza': 'threat',
    'threat': 'threat',
    'caida': 'fall',
    'fall': 'fall',
    'perdida de control': 'loss_control',
    'loss of control': 'loss_control',
    'vuelo': 'flight',
    'flight': 'flight',
    'libertad': 'freedom',
    'freedom': 'freedom',
    'estres': 'stress',
    'stress': 'stress',
    'miedo': 'fear',
    'fear': 'fear',
    'dientes': 'teeth',
    'teeth': 'teeth',
    'examen': 'exam',
    'exam': 'exam',
    'tren': 'train',
    'train': 'train',
    'bosque': 'forest',
    'forest': 'forest',
    'casa': 'house',
    'house': 'house',
  };

  if (dictionary.containsKey(normalized)) {
    return dictionary[normalized];
  }

  for (final entry in dictionary.entries) {
    if (normalized.contains(entry.key)) {
      return entry.value;
    }
  }

  return null;
}

String _normalizeEntityText(String input) {
  final lower = input.toLowerCase();
  const accents = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ñ': 'n',
    'ü': 'u',
  };

  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(accents[ch] ?? ch);
  }
  return buffer.toString();
}

// --- Empty state ---

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MorpheusOrb(size: 120),
            const SizedBox(height: AppSpacing.md),
            Text(
              l.dashboardNoData,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.metrics});

  final _DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final roundedIntensity = metrics.averageMood?.round().clamp(1, 5);
    final intensityLabel = roundedIntensity == null
        ? null
        : IntensityUtils.label(l, roundedIntensity);
    final intensityColor = roundedIntensity == null
        ? AppColors.textPrimary
        : IntensityUtils.color(roundedIntensity);
    final localeCode = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase();
    final morfeoAnalyzedLabel = localeCode.startsWith('es')
        ? 'Analizados por ${l.welcomeMorpheusTitle}'
        : 'Analyzed by ${l.welcomeMorpheusTitle}';

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryMetricTile(
                  label: l.dashboardTotalDreams,
                  value: metrics.totalDreams.toString(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryMetricTile(
                  label: l.dashboardThisMonth,
                  value: metrics.dreamsThisMonth.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _SummaryMetricTile(
                  label: l.dashboardAvgMood,
                  value: intensityLabel ?? '-',
                  valueColor: intensityColor,
                  tileBorderColor: intensityColor,
                  tileBackgroundColor: intensityColor.withValues(alpha: 0.10),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryMetricTile(
                  label: morfeoAnalyzedLabel,
                  value: metrics.aiAnalyzed.toString(),
                  tileBorderColor: AppColors.accentSecondary,
                  tileBackgroundColor: AppColors.accentSecondary.withValues(
                    alpha: 0.10,
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

class _SummaryMetricTile extends StatelessWidget {
  const _SummaryMetricTile({
    required this.label,
    required this.value,
    this.valueColor,
    this.tileBorderColor,
    this.tileBackgroundColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Color? tileBorderColor;
  final Color? tileBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color:
            tileBackgroundColor ??
            AppColors.surfaceGlass.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tileBorderColor ?? AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Morpheus panel ---

class _MorpheusPanel extends StatelessWidget {
  const _MorpheusPanel({required this.dreams});
  final List<Dream> dreams;

  String _generateInsight(AppLocalizations l) {
    if (dreams.isEmpty) return l.dashboardInsightAnalyzing;
    final withMood = dreams.where((d) => d.moodScore != null).toList();
    if (withMood.isEmpty) {
      return l.dashboardInsightNeedMood;
    }
    final avg =
        withMood.map((d) => d.moodScore!).reduce((a, b) => a + b) /
        withMood.length;
    final recent = dreams.length >= 7
        ? dreams.sublist(dreams.length - 7)
        : dreams;
    final recentWithMood = recent.where((d) => d.moodScore != null).toList();
    if (recentWithMood.isNotEmpty) {
      final recentAvg =
          recentWithMood.map((d) => d.moodScore!).reduce((a, b) => a + b) /
          recentWithMood.length;
      if (recentAvg > avg + 0.5) {
        return l.dashboardInsightTrendUp;
      } else if (recentAvg < avg - 0.5) {
        return l.dashboardInsightTrendDown;
      }
    }
    if (avg >= 4) return l.dashboardInsightPositive;
    if (avg >= 3) return l.dashboardInsightNeutral;
    return l.dashboardInsightTense;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassCard(
      radius: AppRadius.lg,
      borderColor: AppColors.accentSecondary.withValues(alpha: 0.40),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MorpheusOrb(size: 64),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l.welcomeMorpheusTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPrimary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSecondary.withValues(
                          alpha: 0.20,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'IA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _generateInsight(l),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
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

// --- Mood chart card ---

class _MoodChartCard extends StatelessWidget {
  const _MoodChartCard({
    required this.dreams,
    required this.range,
    required this.onRangeChanged,
  });

  final List<Dream> dreams;
  final _IntensityRange range;
  final ValueChanged<_IntensityRange> onRangeChanged;

  String _weekLabel(String localeCode) {
    return localeCode == 'es' ? 'Semana' : 'Week';
  }

  String _monthLabel(AppLocalizations l) {
    return l.dashboardThisMonth;
  }

  String _dayLabel(AppLocalizations l, DateTime date) {
    final labels = [
      l.dashboardDayMon,
      l.dashboardDayTue,
      l.dashboardDayWed,
      l.dashboardDayThu,
      l.dashboardDayFri,
      l.dashboardDaySat,
      l.dashboardDaySun,
    ];
    return labels[(date.weekday - 1) % 7];
  }

  String _intensityLabel(AppLocalizations l, double value) {
    final level = value.round().clamp(1, 5);
    switch (level) {
      case 1:
        return l.dreamFormIntensityCalm;
      case 2:
        return l.dreamFormIntensityMild;
      case 3:
        return l.dreamFormIntensityModerate;
      case 4:
        return l.dreamFormIntensityIntense;
      case 5:
        return l.dreamFormIntensityExtreme;
      default:
        return l.dreamFormIntensityModerate;
    }
  }

  List<_MoodPoint> _buildPoints(_IntensityRange range) {
    final now = DateTime.now();
    final days = range == _IntensityRange.week ? 7 : 30;
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));

    final grouped = <DateTime, List<int>>{};
    for (final dream in dreams) {
      if (dream.moodScore == null) continue;
      final day = DateTime(
        dream.dreamDate.year,
        dream.dreamDate.month,
        dream.dreamDate.day,
      );
      if (day.isBefore(start)) continue;
      grouped.putIfAbsent(day, () => <int>[]).add(dream.moodScore!);
    }

    final points = <_MoodPoint>[];
    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final values = grouped[day];
      if (values == null || values.isEmpty) continue;
      final avg = values.reduce((a, b) => a + b) / values.length;
      points.add(_MoodPoint(x: i.toDouble(), y: avg, day: day));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final totalDays = range == _IntensityRange.week ? 7 : 30;
    final rangeStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: totalDays - 1));
    final points = _buildPoints(range);

    if (points.isEmpty) return const SizedBox.shrink();

    final spots = points.map((p) => FlSpot(p.x, p.y)).toList();
    final pointByX = <int, _MoodPoint>{for (final p in points) p.x.toInt(): p};

    return GlassCard(
      radius: AppRadius.md,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart,
                color: AppColors.accentPrimary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l.dashboardMoodEvolution,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              _RangeChip(
                label: _weekLabel(localeCode),
                selected: range == _IntensityRange.week,
                onTap: () => onRangeChanged(_IntensityRange.week),
              ),
              const SizedBox(width: 6),
              _RangeChip(
                label: _monthLabel(l),
                selected: range == _IntensityRange.month,
                onTap: () => onRangeChanged(_IntensityRange.month),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 170,
            child: Row(
              children: [
                _IntensityScaleBar(l: l),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (totalDays - 1).toDouble(),
                      minY: 1,
                      maxY: 5,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.borderSubtle,
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) =>
                              AppColors.surfaceGlass.withValues(alpha: 0.95),
                          tooltipRoundedRadius: 10,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final point = pointByX[spot.x.toInt()];
                              final dateLabel = point == null
                                  ? ''
                                  : range == _IntensityRange.week
                                  ? _dayLabel(l, point.day)
                                  : DateFormat(
                                      'dd/MM',
                                      localeCode,
                                    ).format(point.day);
                              final intensityText = _intensityLabel(l, spot.y);

                              return LineTooltipItem(
                                dateLabel.isEmpty
                                    ? intensityText
                                    : '$dateLabel\n$intensityText',
                                const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= totalDays) {
                                return const SizedBox.shrink();
                              }

                              if (range == _IntensityRange.month &&
                                  idx % 5 != 0) {
                                return const SizedBox.shrink();
                              }

                              final day = rangeStart.add(Duration(days: idx));

                              final label = range == _IntensityRange.week
                                  ? _dayLabel(l, day)
                                  : DateFormat('dd/MM', localeCode).format(day);

                              return Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.4,
                          gradient: LinearGradient(
                            colors: [
                              IntensityUtils.color(1),
                              IntensityUtils.color(2),
                              IntensityUtils.color(3),
                              IntensityUtils.color(4),
                              IntensityUtils.color(5),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, p1, p2, p3) {
                              final rounded = spot.y.round().clamp(1, 5);
                              return FlDotCirclePainter(
                                radius: 4,
                                color: IntensityUtils.color(rounded),
                                strokeColor: AppColors.bgPrimary,
                                strokeWidth: 1.5,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                IntensityUtils.color(5).withValues(alpha: 0.16),
                                IntensityUtils.color(1).withValues(alpha: 0.03),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _IntensityScaleBar extends StatelessWidget {
  const _IntensityScaleBar({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          Text(
            l.dreamFormIntensityExtreme,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    IntensityUtils.color(5),
                    IntensityUtils.color(4),
                    IntensityUtils.color(3),
                    IntensityUtils.color(2),
                    IntensityUtils.color(1),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.dreamFormIntensityMild,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodPoint {
  const _MoodPoint({required this.x, required this.y, required this.day});

  final double x;
  final double y;
  final DateTime day;
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accentColor = AppColors.accentPrimary,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.16)
              : AppColors.surfaceGlass.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? accentColor.withValues(alpha: 0.65)
                : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? accentColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DreamsPerWeekCard extends StatefulWidget {
  const _DreamsPerWeekCard({required this.dreams});

  final List<Dream> dreams;

  @override
  State<_DreamsPerWeekCard> createState() => _DreamsPerWeekCardState();
}

class _DreamsPerWeekCardState extends State<_DreamsPerWeekCard> {
  late DateTime _displayMonth;

  static const Color _dreamDayBlue = Color(0xFF2F80ED);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final monthStart = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final nextMonthStart = DateTime(
      _displayMonth.year,
      _displayMonth.month + 1,
      1,
    );
    final daysInMonth = nextMonthStart.subtract(const Duration(days: 1)).day;

    final dreamCountByDay = <int, int>{};
    for (final dream in widget.dreams) {
      if (dream.dreamDate.year != monthStart.year ||
          dream.dreamDate.month != monthStart.month) {
        continue;
      }
      final day = dream.dreamDate.day;
      dreamCountByDay[day] = (dreamCountByDay[day] ?? 0) + 1;
    }

    final leadingEmptyCells = monthStart.weekday - DateTime.monday;
    final cells = <int?>[
      ...List<int?>.filled(leadingEmptyCells, null),
      ...List<int>.generate(daysInMonth, (index) => index + 1),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final weekRows = <List<int?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weekRows.add(cells.sublist(i, i + 7));
    }

    final weekDayHeaders = List<String>.generate(7, (index) {
      final day = DateTime(2024, 1, index + 1); // Monday..Sunday
      final raw = DateFormat.E(localeCode).format(day);
      return raw.isEmpty ? '' : raw.substring(0, 1).toUpperCase();
    });

    final monthLabel = DateFormat('MMMM yyyy', localeCode).format(monthStart);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.accentSecondary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l.dashboardDreamsPerWeek,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _goToPreviousMonth,
                splashRadius: 16,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: _goToNextMonth,
                splashRadius: 16,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: weekDayHeaders
                      .map(
                        (label) => Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Column(
            children: weekRows.map((week) {
              final weekDreamCount = week.fold<int>(0, (acc, day) {
                if (day == null) return acc;
                return acc + (dreamCountByDay[day] ?? 0);
              });

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: week.map((day) {
                          if (day == null) {
                            return const Expanded(child: SizedBox(height: 28));
                          }

                          final hasDream = (dreamCountByDay[day] ?? 0) > 0;
                          return Expanded(
                            child: Center(
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasDream
                                      ? _dreamDayBlue.withValues(alpha: 0.90)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: hasDream
                                        ? _dreamDayBlue
                                        : AppColors.borderSubtle.withValues(
                                            alpha: 0.50,
                                          ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      color: hasDream
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.surfaceGlass.withValues(alpha: 0.35),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Center(
                        child: Text(
                          '$weekDreamCount',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TopCategoriesCard extends StatelessWidget {
  const _TopCategoriesCard({required this.metrics});

  final _DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.topCategories.isEmpty) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final isEs = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('es');
    final categoriesTitle = isEs
        ? 'Categorías más frecuentes'
        : 'Most frequent categories';
    final categoriesTooltip = isEs
        ? 'Categorías IA: clasificación principal asignada por ${l.welcomeMorpheusTitle} a cada sueño analizado. Se muestran las más repetidas y el número indica cuántas veces aparecen.'
        : 'AI categories: the main classification assigned by ${l.welcomeMorpheusTitle} to each analyzed dream. The list shows the most frequent categories, and the number is the occurrence count.';
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                color: AppColors.accentPrimary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                categoriesTitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Tooltip(
                message: categoriesTooltip,
                triggerMode: TooltipTriggerMode.tap,
                waitDuration: const Duration(milliseconds: 120),
                showDuration: const Duration(seconds: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                textStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2030).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.accentPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: metrics.topCategories
                .map(
                  (e) => _EntityChip(
                    label:
                        '${_localizeEntityLabel(e.key, isSpanish: isEs)} (${e.value})',
                    toneColor: AppColors.accentPrimary,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// --- Recurring elements card (tags as chips) ---

class _RecurringElementsCard extends StatelessWidget {
  const _RecurringElementsCard({required this.metrics});
  final _DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (metrics.topTags.isEmpty) return const SizedBox.shrink();
    final isEs = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('es');
    final tagsTooltip = isEs
        ? 'Etiquetas: palabras clave extraídas (temas y emociones) para agrupar sueños por elementos recurrentes. No representan la categoría principal del sueño.'
        : 'Tags: extracted keywords (themes and emotions) used to group dreams by recurring elements. They are not the dream main category.';

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sell_outlined,
                color: AppColors.accentSecondary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l.dashboardTopTags,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Tooltip(
                message: tagsTooltip,
                triggerMode: TooltipTriggerMode.tap,
                waitDuration: const Duration(milliseconds: 120),
                showDuration: const Duration(seconds: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                textStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2030).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentSecondary.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentSecondary.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.accentSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: metrics.topTags
                .map(
                  (e) => _EntityChip(
                    label:
                        '${_localizeEntityLabel(e.key, isSpanish: isEs)} (${e.value})',
                    toneColor: AppColors.accentSecondary,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _EntityChip extends StatelessWidget {
  const _EntityChip({required this.label, required this.toneColor});
  final String label;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: toneColor.withValues(alpha: 0.50)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// --- Correlation card ---

class _CorrelationCard extends StatefulWidget {
  const _CorrelationCard({required this.dreams});
  final List<Dream> dreams;

  @override
  State<_CorrelationCard> createState() => _CorrelationCardState();
}

class _CorrelationCardState extends State<_CorrelationCard> {
  _IntensityRange _range = _IntensityRange.week;

  int get _minDreamsRequiredForRange {
    return _range == _IntensityRange.week ? 3 : 8;
  }

  List<Dream> _scopedDreams() {
    final now = DateTime.now();
    final totalDays = _range == _IntensityRange.week ? 7 : 30;
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: totalDays - 1));
    return widget.dreams.where((d) {
      final day = DateTime(
        d.dreamDate.year,
        d.dreamDate.month,
        d.dreamDate.day,
      );
      return !day.isBefore(start);
    }).toList();
  }

  List<_CorrelationInsight> _computeInsights(
    List<Dream> sourceDreams, {
    required int minDreamsRequired,
  }) {
    final withMood = sourceDreams.where((d) => d.moodScore != null).toList();
    if (withMood.length < minDreamsRequired) {
      return const [];
    }

    final factors = <_FactorDefinition>[
      _FactorDefinition(
        key: 'water',
        labelEs: 'Agua / inundacion',
        labelEn: 'Water / flooding',
        predicate: (dream) => _containsAny(_dreamCorpus(dream), const [
          'agua',
          'mar',
          'oceano',
          'rio',
          'inund',
          'water',
          'sea',
        ]),
      ),
      _FactorDefinition(
        key: 'pursuit',
        labelEs: 'Persecución / amenaza',
        labelEn: 'Pursuit / threat',
        predicate: (dream) => _containsAny(_dreamCorpus(dream), const [
          'persigu',
          'huia',
          'huir',
          'amenaza',
          'chase',
          'pursuit',
          'threat',
          'followed',
        ]),
      ),
      _FactorDefinition(
        key: 'anxiety',
        labelEs: 'Ansiedad / tension',
        labelEn: 'Anxiety / tension',
        predicate: (dream) => _containsAny(_dreamCorpus(dream), const [
          'ansiedad',
          'estres',
          'miedo',
          'urgencia',
          'anxiety',
          'stress',
          'fear',
          'panic',
        ]),
      ),
      _FactorDefinition(
        key: 'fall',
        labelEs: 'Caída / pérdida de control',
        labelEn: 'Fall / loss of control',
        predicate: (dream) => _containsAny(_dreamCorpus(dream), const [
          'caida',
          'caer',
          'vacio',
          'fall',
          'falling',
          'drop',
        ]),
      ),
      _FactorDefinition(
        key: 'flight',
        labelEs: 'Vuelo / libertad',
        labelEn: 'Flight / freedom',
        predicate: (dream) => _containsAny(_dreamCorpus(dream), const [
          'volar',
          'vuelo',
          'libertad',
          'fly',
          'flight',
          'freedom',
        ]),
      ),
      _FactorDefinition(
        key: 'context_notes',
        labelEs: 'Con notas de contexto',
        labelEn: 'With context notes',
        predicate: (dream) => (dream.contextNotes?.trim().isNotEmpty ?? false),
      ),
    ];

    final insights = <_CorrelationInsight>[];
    for (final factor in factors) {
      final present = <Dream>[];
      final absent = <Dream>[];
      for (final dream in withMood) {
        (factor.predicate(dream) ? present : absent).add(dream);
      }

      if (present.length < 2 || absent.length < 2) {
        continue;
      }

      final r = _pointBiserialCorrelation(
        all: withMood,
        present: present,
        absent: absent,
      );
      if (r == null || r.abs() < 0.08) {
        continue;
      }

      final n = withMood.length;
      final confidence = _confidenceScore(r.abs(), n);
      insights.add(
        _CorrelationInsight(
          key: factor.key,
          labelEs: factor.labelEs,
          labelEn: factor.labelEn,
          coefficient: r,
          confidence: confidence,
          sampleSize: n,
          presentCount: present.length,
        ),
      );
    }

    insights.sort((a, b) => b.coefficient.abs().compareTo(a.coefficient.abs()));
    return insights.take(3).toList();
  }

  static String _dreamCorpus(Dream dream) {
    return [
      dream.title,
      dream.text,
      dream.contextNotes ?? '',
      dream.aiCategory ?? '',
      dream.tags.join(' '),
    ].join(' ').toLowerCase();
  }

  static bool _containsAny(String corpus, List<String> terms) {
    for (final term in terms) {
      if (corpus.contains(term)) {
        return true;
      }
    }
    return false;
  }

  static double? _pointBiserialCorrelation({
    required List<Dream> all,
    required List<Dream> present,
    required List<Dream> absent,
  }) {
    final allValues = all.map((d) => d.moodScore!.toDouble()).toList();
    final std = _stdDev(allValues);
    if (std <= 0) return null;

    final presentMean = _mean(
      present.map((d) => d.moodScore!.toDouble()).toList(),
    );
    final absentMean = _mean(
      absent.map((d) => d.moodScore!.toDouble()).toList(),
    );

    final p = present.length / all.length;
    final q = absent.length / all.length;
    final r = ((presentMean - absentMean) / std) * math.sqrt(p * q);
    if (r.isNaN || r.isInfinite) return null;
    return r.clamp(-1.0, 1.0);
  }

  static double _mean(List<double> values) {
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _stdDev(List<double> values) {
    if (values.length < 2) return 0;
    final avg = _mean(values);
    final variance =
        values.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) /
        (values.length - 1);
    return math.sqrt(variance);
  }

  static double _confidenceScore(double absR, int n) {
    final sizeWeight = (n / 30).clamp(0.35, 1.0);
    return (absR * sizeWeight).clamp(0.0, 1.0);
  }

  static String _strengthLabel(bool isSpanish, double absR) {
    if (absR >= 0.45) return isSpanish ? 'fuerte' : 'strong';
    if (absR >= 0.25) return isSpanish ? 'media' : 'moderate';
    return isSpanish ? 'leve' : 'mild';
  }

  static String _confidenceLabel(bool isSpanish, double confidence) {
    if (confidence >= 0.60) return isSpanish ? 'alta' : 'high';
    if (confidence >= 0.35) return isSpanish ? 'media' : 'medium';
    return isSpanish ? 'baja' : 'low';
  }

  static String _friendlyTrendText({
    required bool isSpanish,
    required String factorLabel,
    required double coefficient,
  }) {
    if (isSpanish) {
      return coefficient >= 0
          ? 'Cuando aparece "$factorLabel", tus sueños tienden a ser más intensos.'
          : 'Cuando aparece "$factorLabel", tus sueños tienden a ser más leves.';
    }
    return coefficient >= 0
        ? 'When "$factorLabel" appears, your dreams tend to be more intense.'
        : 'When "$factorLabel" appears, your dreams tend to be milder.';
  }

  static String _friendlyMetaText({
    required bool isSpanish,
    required String strength,
    required String confidence,
    required int presentCount,
    required int sampleSize,
  }) {
    if (isSpanish) {
      return 'Relación $strength, confianza $confidence. Detectado en $presentCount de $sampleSize sueños.';
    }
    return '$strength relation, $confidence confidence. Seen in $presentCount of $sampleSize dreams.';
  }

  static String _dreamMeaningText({
    required bool isSpanish,
    required String factorKey,
  }) {
    switch (factorKey) {
      case 'water':
        return isSpanish
            ? 'Significado habitual: el agua suele reflejar emociones profundas, cambios internos o sensación de desborde emocional.'
            : 'Typical meaning: water often reflects deep emotions, inner change, or feeling emotionally overwhelmed.';
      case 'pursuit':
        return isSpanish
            ? 'Significado habitual: la persecución suele apuntar a estrés sostenido, evitación o asuntos no resueltos.'
            : 'Typical meaning: pursuit dreams often point to sustained stress, avoidance, or unresolved issues.';
      case 'anxiety':
        return isSpanish
            ? 'Significado habitual: señala tensión mental, autoexigencia o preocupaciones que siguen activas al dormir.'
            : 'Typical meaning: it signals mental tension, self-pressure, or worries that remain active during sleep.';
      case 'fall':
        return isSpanish
            ? 'Significado habitual: la caída se asocia a inseguridad, pérdida de control o miedo a fallar.'
            : 'Typical meaning: falling is linked to insecurity, loss of control, or fear of failure.';
      case 'flight':
        return isSpanish
            ? 'Significado habitual: volar se relaciona con libertad, expansión personal y deseo de superar límites.'
            : 'Typical meaning: flying is associated with freedom, personal expansion, and a wish to go beyond limits.';
      case 'context_notes':
        return isSpanish
            ? 'Significado habitual: registrar contexto suele indicar mayor conciencia emocional y mejor conexión entre día y sueño.'
            : 'Typical meaning: adding context notes usually reflects greater emotional awareness and a clearer day-dream connection.';
      default:
        return isSpanish
            ? 'Significado habitual: este patron puede reflejar un tema emocional recurrente.'
            : 'Typical meaning: this pattern may reflect a recurring emotional theme.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isSpanish = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('es');
    final scopedDreams = _scopedDreams();
    final minDreamsRequired = _minDreamsRequiredForRange;
    final dreamsWithMoodCount = scopedDreams
        .where((d) => d.moodScore != null)
        .length;
    final insights = _computeInsights(
      scopedDreams,
      minDreamsRequired: minDreamsRequired,
    );
    final needMoreMessage = isSpanish
        ? '${l.dashboardCorrelationNeedMore} Mínimo: $minDreamsRequired sueños.'
        : '${l.dashboardCorrelationNeedMore} Minimum: $minDreamsRequired dreams.';

    final summary = insights.isEmpty
        ? (dreamsWithMoodCount < minDreamsRequired
              ? needMoreMessage
              : l.dashboardCorrelationNeedMood)
        : (isSpanish
              ? '${l.welcomeMorpheusTitle} detecta asociaciones estadísticas entre intensidad emocional y factores de tus registros.'
              : '${l.welcomeMorpheusTitle} detects statistical associations between emotional intensity and factors in your records.');

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.warning, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l.dashboardCorrelationTitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              _RangeChip(
                label: isSpanish ? 'Semana' : 'Week',
                selected: _range == _IntensityRange.week,
                accentColor: AppColors.warning,
                onTap: () {
                  setState(() {
                    _range = _IntensityRange.week;
                  });
                },
              ),
              const SizedBox(width: 6),
              _RangeChip(
                label: l.dashboardThisMonth,
                selected: _range == _IntensityRange.month,
                accentColor: AppColors.warning,
                onTap: () {
                  setState(() {
                    _range = _IntensityRange.month;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          if (insights.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...insights.map((insight) {
              final strength = _strengthLabel(
                isSpanish,
                insight.coefficient.abs(),
              );
              final confidence = _confidenceLabel(
                isSpanish,
                insight.confidence,
              );
              final label = isSpanish ? insight.labelEs : insight.labelEn;
              final trendText = _friendlyTrendText(
                isSpanish: isSpanish,
                factorLabel: label,
                coefficient: insight.coefficient,
              );
              final metaText = _friendlyMetaText(
                isSpanish: isSpanish,
                strength: strength,
                confidence: confidence,
                presentCount: insight.presentCount,
                sampleSize: insight.sampleSize,
              );
              final meaningText = _dreamMeaningText(
                isSpanish: isSpanish,
                factorKey: insight.key,
              );

              return Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(
                      insight.coefficient >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: insight.coefficient >= 0
                          ? AppColors.accentSecondary
                          : AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trendText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            metaText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meaningText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _FactorDefinition {
  const _FactorDefinition({
    required this.key,
    required this.labelEs,
    required this.labelEn,
    required this.predicate,
  });

  final String key;
  final String labelEs;
  final String labelEn;
  final bool Function(Dream dream) predicate;
}

class _CorrelationInsight {
  const _CorrelationInsight({
    required this.key,
    required this.labelEs,
    required this.labelEn,
    required this.coefficient,
    required this.confidence,
    required this.sampleSize,
    required this.presentCount,
  });

  final String key;
  final String labelEs;
  final String labelEn;
  final double coefficient;
  final double confidence;
  final int sampleSize;
  final int presentCount;
}
