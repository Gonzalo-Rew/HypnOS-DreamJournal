import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';

import 'package:hypnos_dreamjournal/features/settings/presentation/account_security_screen.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/edit_profile_screen.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/legal_screen.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/notifications_screen.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Ajustes',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                children: [
                  _SectionHeader(label: 'PERFIL Y CUENTA'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _NavTile(
                          icon: Icons.person_outline,
                          label: 'Editar perfil',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          ),
                        ),
                        _settingsDivider(),
                        _NavTile(
                          icon: Icons.shield_outlined,
                          label: 'Cuenta y seguridad',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountSecurityScreen(),
                            ),
                          ),
                        ),
                        _settingsDivider(),
                        _NavTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notificaciones',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionHeader(label: 'PREFERENCIAS'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: _NavTile(
                      icon: Icons.language,
                      label: 'Idioma',
                      onTap: () => _showLanguageSheet(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionHeader(label: 'INTELIGENCIA ARTIFICIAL'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.accentSecondary,
                        size: 20,
                      ),
                      title: const Text(
                        'Morfeo – Análisis con IA',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Activo · gestionado por el servidor',
                        style: TextStyle(
                          color: AppColors.accentSecondary,
                          fontSize: 11,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionHeader(label: 'LEGAL'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _NavTile(
                          icon: Icons.description_outlined,
                          label: 'Política de privacidad',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LegalScreen(type: LegalDocType.privacy),
                            ),
                          ),
                        ),
                        _settingsDivider(),
                        _NavTile(
                          icon: Icons.menu_book_outlined,
                          label: 'Términos y condiciones',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LegalScreen(type: LegalDocType.terms),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Center(child: HypnosGradientLogo(fontSize: 22)),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2230),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Idioma',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                title: const Text(
                  'English',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Text('🇪🇸', style: TextStyle(fontSize: 22)),
                title: const Text(
                  'Español',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.xs),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accentPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: 14,
      ),
      onTap: onTap,
    );
  }
}

Widget _settingsDivider() => const Divider(
  height: 1,
  color: AppColors.borderSubtle,
  indent: AppSpacing.md,
  endIndent: AppSpacing.md,
);
