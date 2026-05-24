import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dashboard/presentation/dashboard_refresh_bus.dart';
import 'package:hypnos_dreamjournal/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_form_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dreams_list_screen.dart';
import 'package:hypnos_dreamjournal/features/home/presentation/home_screen.dart';
import 'package:hypnos_dreamjournal/features/profile/presentation/profile_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Root shell for authenticated users.
/// Hosts the 4 main tabs with a glassmorphism bottom navigation bar
/// and a gradient FAB for quick dream capture.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  // Allows external callers (e.g. post-save screens) to switch the active tab.
  static _MainShellState? _instance;
  static void switchToTab(int index) => _instance?._onTabTapped(index);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _showTutorial = false;
  int _tutorialIndex = 0;

  final GlobalKey _homeTabKey = GlobalKey(debugLabel: 'homeTabKey');
  final GlobalKey _dreamsTabKey = GlobalKey(debugLabel: 'dreamsTabKey');
  final GlobalKey _dashboardTabKey = GlobalKey(debugLabel: 'dashboardTabKey');
  final GlobalKey _profileTabKey = GlobalKey(debugLabel: 'profileTabKey');
  final GlobalKey _fabKey = GlobalKey(debugLabel: 'fabKey');

  late final List<_TutorialStep> _tutorialSteps = [
    _TutorialStep(
      key: _homeTabKey,
      title: 'Inicio',
      description:
          'Aquí verás un resumen de tu actividad y los sueños recientes.',
    ),
    _TutorialStep(
      key: _dreamsTabKey,
      title: 'Sueños',
      description: 'En Sueños puedes ver, editar y organizar todos tus sueños.',
    ),
    _TutorialStep(
      key: _dashboardTabKey,
      title: 'Dashboard',
      description:
          'Aquí Morfeo te muestra patrones, tendencias y categorías detectadas.',
    ),
    _TutorialStep(
      key: _profileTabKey,
      title: 'Perfil',
      description:
          'Desde Perfil gestionas tu cuenta, seguidores y sueños publicados.',
    ),
    _TutorialStep(
      key: _fabKey,
      title: 'Nuevo sueño',
      description:
          'Pulsa aquí para registrar un sueño nuevo por texto o audio.',
    ),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    DreamsListScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    MainShell._instance = this;
    _maybeShowFirstTimeTutorial();
  }

  @override
  void dispose() {
    if (MainShell._instance == this) MainShell._instance = null;
    super.dispose();
  }

  Future<void> _maybeShowFirstTimeTutorial() async {
    final uid = FirebaseService.getCurrentUserId();
    if (uid == null) return;

    final doc = await FirebaseService.firestore
        .collection('users')
        .doc(uid)
        .get();
    final seen = doc.data()?['hasTutorialSeen'] as bool? ?? false;
    if (seen || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showTutorial = true;
        _tutorialIndex = 0;
      });
    });
  }

  Future<void> _finishTutorial() async {
    final uid = FirebaseService.getCurrentUserId();
    if (uid != null) {
      await FirebaseService.firestore.collection('users').doc(uid).update({
        'hasTutorialSeen': true,
      });
    }
    if (!mounted) return;
    setState(() => _showTutorial = false);
  }

  void _nextTutorialStep() {
    if (_tutorialIndex >= _tutorialSteps.length - 1) {
      _finishTutorial();
      return;
    }

    final nextIndex = _tutorialIndex + 1;
    final nextTab = _tutorialStepToTab(nextIndex);

    if (nextTab == 2) {
      DashboardRefreshBus.notifyRefreshRequested();
    }

    setState(() {
      _tutorialIndex = nextIndex;
      _currentIndex = nextTab;
    });
  }

  int _tutorialStepToTab(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      case 4:
        return 0;
      default:
        return 0;
    }
  }

  Rect? _currentTutorialTargetRect() {
    final key = _tutorialSteps[_tutorialIndex].key;
    final ctx = key.currentContext;
    if (ctx == null) return null;

    final box = ctx.findRenderObject();
    if (box is! RenderBox) return null;

    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      DashboardRefreshBus.notifyRefreshRequested();
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _openNewDream() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const DreamFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final step = _showTutorial ? _tutorialSteps[_tutorialIndex] : null;
    final targetRect = _showTutorial ? _currentTutorialTargetRect() : null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: IndexedStack(index: _currentIndex, children: _screens),
          floatingActionButton: _GradientFab(
            key: _fabKey,
            onPressed: _openNewDream,
            isEmphasized: _showTutorial && _tutorialIndex == 4,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _GlassBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            tabKeys: [
              _homeTabKey,
              _dreamsTabKey,
              _dashboardTabKey,
              _profileTabKey,
            ],
          ),
        ),
        if (_showTutorial && step != null)
          _TutorialOverlay(
            targetRect: targetRect,
            title: step.title,
            description: step.description,
            stepNumber: _tutorialIndex + 1,
            stepCount: _tutorialSteps.length,
            isLast: _tutorialIndex == _tutorialSteps.length - 1,
            onNext: _nextTutorialStep,
            onSkip: _finishTutorial,
          ),
      ],
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({
    super.key,
    required this.onPressed,
    this.isEmphasized = false,
  });

  final VoidCallback onPressed;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final size = isEmphasized ? 76.0 : 60.0;
    final iconSize = isEmphasized ? 36.0 : 28.0;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.accentPrimary, AppColors.accentSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withValues(
                alpha: isEmphasized ? 0.58 : 0.40,
              ),
              blurRadius: isEmphasized ? 30 : 20,
              spreadRadius: isEmphasized ? 4 : 2,
            ),
          ],
        ),
        child: Icon(Icons.add, color: AppColors.bgPrimary, size: iconSize),
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.tabKeys,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlobalKey> tabKeys;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: l.homeTitle,
      ),
      _NavItem(
        icon: Icons.auto_stories_outlined,
        activeIcon: Icons.auto_stories,
        label: l.dreamsListTitle,
      ),
      _NavItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        label: l.dashboardTitle,
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: l.profileTitle,
      ),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceGlass,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                children: List.generate(items.length, (i) {
                  if (i == 2) {
                    return [
                      const SizedBox(width: 60),
                      _NavButton(
                        key: tabKeys[i],
                        item: items[i],
                        isActive: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    ];
                  }

                  return [
                    _NavButton(
                      key: tabKeys[i],
                      item: items[i],
                      isActive: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                  ];
                }).expand((w) => w).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.accentPrimary
        : AppColors.textPrimary.withValues(alpha: 0.45);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.accentPrimary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep {
  const _TutorialStep({
    required this.key,
    required this.title,
    required this.description,
  });

  final GlobalKey key;
  final String title;
  final String description;
}

class _TutorialOverlay extends StatelessWidget {
  const _TutorialOverlay({
    required this.targetRect,
    required this.title,
    required this.description,
    required this.stepNumber,
    required this.stepCount,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final Rect? targetRect;
  final String title;
  final String description;
  final int stepNumber;
  final int stepCount;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final preferredTop = MediaQuery.of(context).padding.top + 64;
    final safeTop = preferredTop.clamp(
      72.0,
      MediaQuery.of(context).size.height - 290,
    );

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _TutorialMaskPainter(targetRect: targetRect),
              ),
            ),
            Positioned(
              right: AppSpacing.md,
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
                child: const Text('Saltar tutorial'),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: safeTop,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2230).withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const MorpheusOrb(size: 34),
                        const SizedBox(width: AppSpacing.sm),
                        const Text(
                          'Morfeo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$stepNumber/$stepCount',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPrimary,
                          foregroundColor: AppColors.bgPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(isLast ? 'Empezar' : 'Siguiente'),
                      ),
                    ),
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

class _TutorialMaskPainter extends CustomPainter {
  _TutorialMaskPainter({required this.targetRect});

  final Rect? targetRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()..addRect(Offset.zero & size);
    final rrect = (targetRect ?? Rect.zero).inflate(10);

    if (targetRect != null) {
      overlayPath.addRRect(
        RRect.fromRectAndRadius(rrect, const Radius.circular(14)),
      );
      overlayPath.fillType = PathFillType.evenOdd;
    }

    final paint = Paint()..color = const Color(0xCC424242);
    canvas.drawPath(overlayPath, paint);

    if (targetRect != null) {
      final borderPaint = Paint()
        ..color = AppColors.accentPrimary.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rrect, const Radius.circular(14)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TutorialMaskPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}
