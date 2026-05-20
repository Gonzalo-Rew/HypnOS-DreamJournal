import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_form_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dreams_list_screen.dart';
import 'package:hypnos_dreamjournal/features/home/presentation/home_screen.dart';
import 'package:hypnos_dreamjournal/features/profile/presentation/profile_screen.dart';

/// Root shell for authenticated users.
/// Hosts the 4 main tabs with a glassmorphism bottom navigation bar
/// and a gradient FAB for quick dream capture (hidden on Profile tab).
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

  @override
  void initState() {
    super.initState();
    MainShell._instance = this;
  }

  @override
  void dispose() {
    if (MainShell._instance == this) MainShell._instance = null;
    super.dispose();
  }

  // Keep screens alive between tabs using IndexedStack
  final List<Widget> _screens = const [
    HomeScreen(),
    DreamsListScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  // Navigate to new-dream form from FAB
  Future<void> _openNewDream() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const DreamFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      // IndexedStack keeps each screen's state alive
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _GradientFab(onPressed: _openNewDream),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ─── Gradient FAB ────────────────────────────────────────────────────────────

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.accentPrimary, AppColors.accentSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withValues(alpha: 0.40),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.bgPrimary, size: 28),
      ),
    );
  }
}

// ─── Glass bottom nav ─────────────────────────────────────────────────────────

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
    ),
    _NavItem(
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      label: 'Diario',
    ),
    _NavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      label: 'Análisis',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                children: List.generate(_items.length, (i) {
                  // Leave space in the center for the FAB (2 items left, gap, 2 items right)
                  // Insert gap between index 1 and 2
                  if (i == 2) {
                    return [
                      const SizedBox(width: 60), // FAB gap
                      _NavButton(
                        item: _items[i],
                        isActive: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    ];
                  }
                  return [
                    _NavButton(
                      item: _items[i],
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
            // Active indicator pill
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
