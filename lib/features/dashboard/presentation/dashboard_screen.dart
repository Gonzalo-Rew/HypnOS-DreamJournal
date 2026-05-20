import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/settings_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/errors/error_messages.dart';
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
        _errorMessage = 'Sesión no iniciada. Vuelve a iniciar sesión.';
      });
      return;
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
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
                          _MoodChartCard(dreams: _dreams),
                          const SizedBox(height: AppSpacing.md),
                          _RecurringElementsCard(dreams: _dreams),
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

// --- Morpheus panel ---

class _MorpheusPanel extends StatelessWidget {
  const _MorpheusPanel({required this.dreams});
  final List<Dream> dreams;

  String _generateInsight() {
    if (dreams.isEmpty) return 'Morfeo esta analizando tus suenos.';
    final withMood = dreams.where((d) => d.moodScore != null).toList();
    if (withMood.isEmpty)
      return 'Registra el estado de animo en tus suenos para obtener correlaciones.';
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
        return 'Tu estado emocional en suenos ha mejorado esta semana. Morfeo detecta una tendencia positiva.';
      } else if (recentAvg < avg - 0.5) {
        return 'Tus suenos recientes muestran mayor intensidad emocional. Considera revisar tus habitos de sueno.';
      }
    }
    if (avg >= 4)
      return 'Tus suenos reflejan un estado emocional positivo de forma consistente.';
    if (avg >= 3)
      return 'Estado emocional neutro en tus suenos. Morfeo no detecta patrones de alerta.';
    return 'Morfeo detecta tension emocional recurrente. Considera tecnicas de relajacion antes de dormir.';
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Morfeo',
                      style: TextStyle(
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
                  _generateInsight(),
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
  const _MoodChartCard({required this.dreams});
  final List<Dream> dreams;

  @override
  Widget build(BuildContext context) {
    final withMood = dreams.where((d) => d.moodScore != null).toList();
    final data = withMood.length > 7
        ? withMood.sublist(withMood.length - 7)
        : withMood;

    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.moodScore!.toDouble());
    }).toList();

    final dayLabels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];

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
                'TONO EMOCIONAL (7 DIAS)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
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
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final dayIdx = data[idx].dreamDate.weekday - 1;
                        return Text(
                          dayLabels[dayIdx % 7],
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
                    color: AppColors.accentPrimary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, p1, p2, p3) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.accentPrimary,
                        strokeColor: AppColors.bgPrimary,
                        strokeWidth: 1.5,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentPrimary.withValues(alpha: 0.30),
                          AppColors.accentPrimary.withValues(alpha: 0.00),
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
    );
  }
}

// --- Recurring elements card (tags as chips) ---

class _RecurringElementsCard extends StatelessWidget {
  const _RecurringElementsCard({required this.dreams});
  final List<Dream> dreams;

  @override
  Widget build(BuildContext context) {
    final freq = <String, int>{};
    for (final d in dreams) {
      for (final tag in d.tags) {
        final t = tag.trim();
        if (t.isNotEmpty) freq[t] = (freq[t] ?? 0) + 1;
      }
    }
    if (freq.isEmpty) return const SizedBox.shrink();

    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bubble_chart_outlined,
                color: AppColors.accentSecondary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'ELEMENTOS RECURRENTES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: top.map((e) => _EntityChip(label: e.key)).toList(),
          ),
        ],
      ),
    );
  }
}

class _EntityChip extends StatelessWidget {
  const _EntityChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSecondary.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.50),
        ),
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

class _CorrelationCard extends StatelessWidget {
  const _CorrelationCard({required this.dreams});
  final List<Dream> dreams;

  String _correlation() {
    if (dreams.length < 5) {
      return 'Necesitas mas registros para detectar correlaciones. Sigue anadiendo suenos cada dia.';
    }
    final withMood = dreams.where((d) => d.moodScore != null).toList();
    if (withMood.isEmpty)
      return 'Valora el estado de animo de tus suenos para activar el analisis de correlacion.';
    final avg =
        withMood.map((d) => d.moodScore!).reduce((a, b) => a + b) /
        withMood.length;
    if (avg >= 4)
      return 'Tus suenos intensos coinciden con dias de alta energia y actividad positiva.';
    if (avg >= 3)
      return 'Morfeo detecta estabilidad emocional. Tus suenos reflejan tu ritmo diario.';
    return 'Tus suenos intensos coinciden con dias de alta actividad o estres. Considera rutinas de relajacion nocturna.';
  }

  @override
  Widget build(BuildContext context) {
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
                'CORRELACION',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _correlation(),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
