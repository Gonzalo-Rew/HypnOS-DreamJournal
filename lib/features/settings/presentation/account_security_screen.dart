import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final AuthRepository _authRepo = AuthRepositoryImpl();

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String _dreamVisibility = 'public';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _authRepo.getCurrentUser();
    if (!mounted) return;
    if (result is Success<User>) {
      final u = result.value;
      setState(() {
        _user = u;
        _dreamVisibility = u.dreamVisibility;
        _isLoading = false;
      });
    } else {
      final authUser = FirebaseService.getCurrentUser();
      if (authUser != null) {
        setState(() {
          _user = User(
            id: authUser.uid,
            email: authUser.email ?? '',
            displayName: authUser.displayName ?? '',
            createdAt: DateTime.now(),
            aiEnabled: true,
            timezone: 'UTC',
            notificationsEnabled: false,
            notificationTime: '08:00',
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    final local = parts[0];
    final masked = local[0] + '*' * (local.length - 1).clamp(2, 5);
    return '$masked@${parts[1]}';
  }

  String _visibilityLabel(String v) {
    switch (v) {
      case 'public':
        return 'Todo el mundo';
      case 'followers':
        return 'Solo seguidores';
      default:
        return 'Privado';
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _user?.email ?? '';
    if (email.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2230),
        title: const Text(
          'Restablecer contraseña',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Te enviaremos un enlace a $email.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Enviar enlace',
              style: TextStyle(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _authRepo.sendPasswordResetEmail(email: email);
    if (!mounted) return;
    if (result is Success) {
      await _showEmailSentDialog(email);
    } else {
      _showSnack('Error al enviar el enlace', isError: true);
    }
  }

  Future<void> _showEmailSentDialog(String email) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentPrimary.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.12),
                blurRadius: 48,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con halo
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentPrimary.withOpacity(0.18),
                      AppColors.accentSecondary.withOpacity(0.18),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.accentPrimary.withOpacity(0.45),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.accentPrimary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                '¡Correo enviado!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Hemos enviado un enlace de\nrestablecimiento a ',
                    ),
                    TextSpan(
                      text: email,
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text: '\n\nRevisa también tu carpeta de spam.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: AppColors.bgPrimary,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVisibilitySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2230),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VisibilitySheet(
        current: _dreamVisibility,
        onSelected: (v) async {
          setState(() => _dreamVisibility = v);
          await FirebaseService.firestore
              .collection('users')
              .doc(_user!.id)
              .update({'dreamVisibility': v});
          if (!mounted) return;
          _showSnack('Visibilidad actualizada');
        },
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await _confirm(
      title: 'Cerrar sesión',
      message: '¿Seguro que quieres cerrar sesión?',
      label: 'Cerrar sesión',
      destructive: false,
    );
    if (confirmed != true || !mounted) return;
    await _authRepo.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _confirm(
      title: 'Eliminar cuenta',
      message:
          'Esta acción es permanente e irreversible. Todos tus datos serán eliminados.',
      label: 'Eliminar cuenta',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseService.getCurrentUser()?.uid;
      if (uid != null) {
        await FirebaseService.firestore.collection('users').doc(uid).delete();
      }
      await FirebaseService.auth.currentUser?.delete();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack(
        'Debes volver a iniciar sesión para eliminar tu cuenta',
        isError: true,
      );
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String label,
    required bool destructive,
  }) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E2230),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            label,
            style: TextStyle(
              color: destructive ? AppColors.error : AppColors.accentPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.accentPrimary,
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    color: AppColors.borderSubtle,
    indent: AppSpacing.md,
    endIndent: AppSpacing.md,
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentPrimary),
        ),
      );
    }
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
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
                    'Cuenta y seguridad',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                children: [
                  // CREDENCIALES
                  _SubLabel(label: 'CREDENCIALES'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.mail_outline,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: const Text(
                            'Correo electrónico',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            user != null ? _maskedEmail(user.email) : '—',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        _divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.lock_outline,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: const Text(
                            'Cambiar contraseña',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                          onTap: _sendPasswordReset,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // PRIVACIDAD
                  _SubLabel(label: 'PRIVACIDAD'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(
                        Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      title: const Text(
                        'Visibilidad de los sueños',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _visibilityLabel(_dreamVisibility),
                            style: const TextStyle(
                              color: AppColors.accentPrimary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.expand_more,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                      onTap: _showVisibilitySheet,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ACCIONES DE CUENTA
                  _SubLabel(label: 'ACCIONES DE CUENTA'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          title: const Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 14,
                            ),
                          ),
                          onTap: _logout,
                        ),
                        _divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_forever_outlined,
                            color: AppColors.error,
                            size: 20,
                          ),
                          title: const Text(
                            'Eliminar cuenta',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                          onTap: _isSaving ? null : _deleteAccount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Text(
                      'Estas acciones son permanentes y no se pueden deshacer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SubLabel extends StatelessWidget {
  const _SubLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
        top: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ── Visibility bottom sheet ───────────────────────────────────────────────────

class _VisibilitySheet extends StatelessWidget {
  const _VisibilitySheet({required this.current, required this.onSelected});
  final String current;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        value: 'public',
        icon: Icons.public,
        title: 'Todo el mundo',
        subtitle: 'Tus sueños están disponibles públicamente.',
      ),
      (
        value: 'followers',
        icon: Icons.group,
        title: 'Solo seguidores',
        subtitle: 'Solo quienes te siguen pueden ver tus sueños.',
      ),
      (
        value: 'private',
        icon: Icons.lock,
        title: 'Privado',
        subtitle: 'Nadie puede ver tus sueños.',
      ),
    ];

    return SafeArea(
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
              'Visibilidad de los sueños',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final opt in options)
              GestureDetector(
                onTap: () {
                  onSelected(opt.value);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: current == opt.value
                        ? AppColors.accentPrimary.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: current == opt.value
                          ? AppColors.accentPrimary
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        opt.icon,
                        color: current == opt.value
                            ? AppColors.accentPrimary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.title,
                              style: TextStyle(
                                color: current == opt.value
                                    ? AppColors.accentPrimary
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              opt.subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (current == opt.value)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.accentPrimary,
                          size: 18,
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
