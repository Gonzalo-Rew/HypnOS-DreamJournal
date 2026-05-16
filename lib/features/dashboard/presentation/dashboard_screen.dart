import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DreamRepository _dreamRepository = DreamRepositoryImpl();

  bool _isLoading = true;
  String? _errorMessage;
  List<Dream> _dreams = [];

  @override
  void initState() {
    super.initState();
    _loadDreams();
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
        _errorMessage = 'Not logged in';
      });
      return;
    }
    final result = await _dreamRepository.getDreamsByUser(userId: uid, limit: 200);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result is Success<List<Dream>>) {
        _dreams = result.value;
        _dreams.sort((a, b) => a.dreamDate.compareTo(b.dreamDate));
      } else {
        _errorMessage = (result as Failure<List<Dream>>).exception.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDreams,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _dreams.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          l.dashboardNoData,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDreams,
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          _SummaryRow(dreams: _dreams, l: l),
                          const SizedBox(height: AppSpacing.lg),
                          _MoodEvolutionChart(dreams: _dreams, l: l),
                          const SizedBox(height: AppSpacing.lg),
                          _DreamsPerWeekChart(dreams: _dreams, l: l),
                          const SizedBox(height: AppSpacing.lg),
                          _TopCategoriesCard(dreams: _dreams, l: l),
                          const SizedBox(height: AppSpacing.lg),
                          _TopTagsCard(dreams: _dreams, l: l),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
    );
  }
}

// ─── Summary row ────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.dreams, required this.l});

  final List<Dream> dreams;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonth = dreams
        .where((d) => d.dreamDate.year == now.year && d.dreamDate.month == now.month)
        .length;
    final withMood = dreams.where((d) => d.moodScore != null).toList();
    final avgMood = withMood.isEmpty
        ? null
        : withMood.map((d) => d.moodScore!).reduce((a, b) => a + b) /
            withMood.length;
    final aiAnalyzed = dreams
        .where((d) => d.aiSummary != null && d.aiSummary!.isNotEmpty)
        .length;
    final aiPct =
        dreams.isEmpty ? 0 : ((aiAnalyzed / dreams.length) * 100).round();

    return Row(
      children: [
        _StatCard(
          label: l.dashboardTotalDreams,
          value: '${dreams.length}',
          icon: Icons.nights_stay,
          color: AppColors.accentPrimary,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          label: l.dashboardThisMonth,
          value: '$thisMonth',
          icon: Icons.calendar_month,
          color: AppColors.accentSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          label: l.dashboardAvgMood,
          value: avgMood == null ? '-' : avgMood.toStringAsFixed(1),
          icon: Icons.mood,
          color: _moodColor(avgMood),
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          label: l.dashboardAiAnalyzed,
          value: '$aiPct%',
          icon: Icons.auto_awesome,
          color: Colors.purpleAccent,
        ),
      ],
    );
  }

  Color _moodColor(double? mood) {
    if (mood == null) return Colors.grey;
    if (mood >= 4) return Colors.green;
    if (mood >= 3) return Colors.amber;
    return Colors.redAccent;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mood evolution chart ────────────────────────────────────────────────────

class _MoodEvolutionChart extends StatelessWidget {
  const _MoodEvolutionChart({required this.dreams, required this.l});

  final List<Dream> dreams;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final withMood = dreams.where((d) => d.moodScore != null).toList();
    final data = withMood.length > 30 ? withMood.sublist(withMood.length - 30) : withMood;

    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.moodScore!.toDouble());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.dashboardMoodEvolution,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 1,
                  maxY: 5,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white12,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 24,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.accentPrimary,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.accentPrimary,
                          strokeColor: Colors.transparent,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accentPrimary.withAlpha(40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'últimos ${data.length} sueños con ánimo',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dreams per week chart ───────────────────────────────────────────────────

class _DreamsPerWeekChart extends StatelessWidget {
  const _DreamsPerWeekChart({required this.dreams, required this.l});

  final List<Dream> dreams;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    // Build last 8 ISO weeks
    final now = DateTime.now();
    final weeks = <DateTime>[];
    for (int i = 7; i >= 0; i--) {
      final monday = _mondayOf(now.subtract(Duration(days: i * 7)));
      weeks.add(monday);
    }

    final counts = weeks.map((monday) {
      final sunday = monday.add(const Duration(days: 6));
      return dreams
          .where((d) =>
              !d.dreamDate.isBefore(monday) &&
              !d.dreamDate.isAfter(sunday.copyWith(hour: 23, minute: 59)))
          .length;
    }).toList();

    final maxCount = counts.reduce(math.max).toDouble();

    final bars = counts.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            color: AppColors.accentSecondary,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.dashboardDreamsPerWeek,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: maxCount < 1 ? 1 : maxCount + 1,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white12,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 24,
                        getTitlesWidget: (v, _) => v == v.floorToDouble()
                            ? Text(
                                '${v.toInt()}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= weeks.length) return const SizedBox.shrink();
                          final w = weeks[idx];
                          return Text(
                            '${w.day}/${w.month}',
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: bars,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _mondayOf(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }
}

// ─── Top categories card ─────────────────────────────────────────────────────

class _TopCategoriesCard extends StatelessWidget {
  const _TopCategoriesCard({required this.dreams, required this.l});

  final List<Dream> dreams;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final freq = <String, int>{};
    for (final d in dreams) {
      if (d.aiCategory != null && d.aiCategory!.trim().isNotEmpty) {
        freq[d.aiCategory!.trim()] = (freq[d.aiCategory!.trim()] ?? 0) + 1;
      }
    }
    if (freq.isEmpty) return const SizedBox.shrink();

    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = freq.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.dashboardTopCategories,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...top.asMap().entries.map((e) {
              final pct = (e.value.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RankRow(
                  rank: e.key + 1,
                  label: e.value.key,
                  count: e.value.value,
                  pct: pct,
                  color: _categoryColor(e.key),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(int index) {
    const colors = [
      Colors.deepPurpleAccent,
      Colors.tealAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.lightBlueAccent,
    ];
    return colors[index % colors.length];
  }
}

// ─── Top tags card ───────────────────────────────────────────────────────────

class _TopTagsCard extends StatelessWidget {
  const _TopTagsCard({required this.dreams, required this.l});

  final List<Dream> dreams;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final freq = <String, int>{};
    for (final d in dreams) {
      for (final tag in d.tags) {
        if (tag.trim().isNotEmpty) {
          freq[tag.trim()] = (freq[tag.trim()] ?? 0) + 1;
        }
      }
    }
    if (freq.isEmpty) return const SizedBox.shrink();

    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(7).toList();
    final total = freq.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.dashboardTopTags,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...top.asMap().entries.map((e) {
              final pct = (e.value.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RankRow(
                  rank: e.key + 1,
                  label: '#${e.value.key}',
                  count: e.value.value,
                  pct: pct,
                  color: AppColors.accentPrimary.withAlpha(200),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Shared rank row widget ──────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.label,
    required this.count,
    required this.pct,
    required this.color,
  });

  final int rank;
  final String label;
  final int count;
  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '$rank',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$count  ($pct%)',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

extension on DateTime {
  DateTime copyWith({int? year, int? month, int? day, int? hour, int? minute, int? second}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }
}
