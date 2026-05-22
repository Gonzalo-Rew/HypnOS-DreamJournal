import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/core/config/app_settings.dart';
import 'package:hypnos_dreamjournal/core/constants/app_constants.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/utils/biometric_auth_service.dart';
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
  bool _isBiometricLoading = true;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  String _dreamVisibility = 'followers';

  String _normalizeVisibility(String? value) {
    return value == 'public' ? 'public' : 'followers';
  }

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
      final normalizedVisibility = _normalizeVisibility(u.dreamVisibility);
      setState(() {
        _user = u;
        _dreamVisibility = normalizedVisibility;
        _isLoading = false;
      });
      if (normalizedVisibility != u.dreamVisibility) {
        try {
          await FirebaseService.firestore.collection('users').doc(u.id).update({
            'dreamVisibility': normalizedVisibility,
          });
        } catch (_) {}
      }
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

    await _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final enabled = await AppSettings.instance.getBiometricEnabled();
    final supported =
        FeatureFlags.enableBiometricAuth &&
        await BiometricAuthService.instance.isAvailable();
    if (!mounted) return;
    setState(() {
      _biometricSupported = supported;
      _biometricEnabled = enabled && supported;
      _isBiometricLoading = false;
    });
  }

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    final local = parts[0];
    final masked = local[0] + '*' * (local.length - 1).clamp(2, 5);
    return '$masked@${parts[1]}';
  }

  Future<String?> _requestBiometricPassword() async {
    final controller = TextEditingController();
    bool obscure = true;
    String? error;

    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2230),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accentPrimary.withOpacity(0.22),
                width: 1.1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fingerprint,
                  color: AppColors.accentPrimary,
                  size: 44,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(
                    context,
                  ).accountSecurityBiometricDialogTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).accountSecurityBiometricDialogMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).accountSecurityCurrentPasswordLabel,
                    errorText: error,
                    filled: true,
                    fillColor: AppColors.surfaceGlass.withOpacity(0.6),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setDialogState(() => obscure = !obscure),
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  onSubmitted: (_) {
                    final value = controller.text.trim();
                    if (value.isEmpty) {
                      setDialogState(
                        () => error = AppLocalizations.of(
                          context,
                        ).validationPasswordRequired,
                      );
                      return;
                    }
                    Navigator.pop(ctx, value);
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          AppLocalizations.of(context).dreamDetailDeleteCancel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final value = controller.text.trim();
                          if (value.isEmpty) {
                            setDialogState(
                              () => error = AppLocalizations.of(
                                context,
                              ).validationPasswordRequired,
                            );
                            return;
                          }
                          Navigator.pop(ctx, value);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPrimary,
                          foregroundColor: AppColors.bgPrimary,
                        ),
                        child: Text(
                          AppLocalizations.of(context).accountSecurityActivate,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setBiometricEnabled(bool enabled) async {
    if (_isBiometricLoading || !_biometricSupported) return;

    if (!enabled) {
      await AppSettings.instance.setBiometricEnabled(false);
      await BiometricAuthService.instance.clearCredentials();
      if (!mounted) return;
      setState(() => _biometricEnabled = false);
      _showSnack(AppLocalizations.of(context).accountSecurityBiometricDisabled);
      return;
    }

    final currentUser = FirebaseService.getCurrentUser();
    final email = currentUser?.email ?? '';
    final hasPasswordProvider =
        currentUser?.providerData.any(
          (info) => info.providerId == 'password',
        ) ??
        false;
    if (currentUser == null || email.isEmpty || !hasPasswordProvider) {
      _showSnack(
        AppLocalizations.of(context).accountSecurityBiometricPasswordOnly,
        isError: true,
      );
      return;
    }

    final password = await _requestBiometricPassword();
    if (password == null || !mounted) return;

    try {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
      await BiometricAuthService.instance.saveCredentials(
        email: email,
        password: password,
      );
      await AppSettings.instance.setBiometricEnabled(true);
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
      _showSnack(AppLocalizations.of(context).accountSecurityBiometricEnabled);
    } on firebase_auth.FirebaseAuthException catch (_) {
      if (!mounted) return;
      _showSnack(
        AppLocalizations.of(context).authErrorWrongPassword,
        isError: true,
      );
      setState(() => _biometricEnabled = false);
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        AppLocalizations.of(context).accountSecurityBiometricEnableFailed,
        isError: true,
      );
      setState(() => _biometricEnabled = false);
    }
  }

  String _visibilityLabel(String v) {
    final l = AppLocalizations.of(context);
    switch (v) {
      case 'public':
        return l.accountSecurityVisibilityEveryone;
      case 'followers':
        return l.accountSecurityVisibilityFollowers;
      default:
        return l.accountSecurityVisibilityFollowers;
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _user?.email ?? '';
    if (email.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
                blurRadius: 44,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentPrimary.withOpacity(0.20),
                      AppColors.accentSecondary.withOpacity(0.20),
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
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context).accountSecurityResetPasswordTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(
                  context,
                ).accountSecurityResetPasswordMessage(email),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).dreamDetailDeleteCancel,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPrimary,
                        foregroundColor: AppColors.bgPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).accountSecurityResetPasswordSendLink,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _authRepo.sendPasswordResetEmail(email: email);
    if (!mounted) return;
    if (result is Success) {
      await _showEmailSentDialog(email);
    } else {
      _showSnack(
        AppLocalizations.of(context).accountSecurityResetPasswordSendError,
        isError: true,
      );
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
              Text(
                AppLocalizations.of(context).accountSecurityEmailSentTitle,
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
                    TextSpan(
                      text: AppLocalizations.of(
                        context,
                      ).accountSecurityEmailSentPrefix,
                    ),
                    TextSpan(
                      text: email,
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(
                        context,
                      ).accountSecurityEmailSentSuffix,
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
                  child: Text(
                    AppLocalizations.of(context).dreamAnalysisUnderstood,
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
          _showSnack(
            AppLocalizations.of(context).accountSecurityVisibilityUpdated,
          );
        },
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await _confirm(
      title: AppLocalizations.of(context).profileLogoutButton,
      message: AppLocalizations.of(context).accountSecurityLogoutConfirmMessage,
    );
    if (confirmed != true || !mounted) return;
    await _authRepo.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
  }

  Future<void> _deleteAccount() async {
    final password = await _requestDeletePassword();
    if (password == null || !mounted) return;

    setState(() => _isSaving = true);
    final result = await _authRepo.deleteAccountWithPassword(
      password: password,
    );
    if (!mounted) return;
    if (result is Success<void>) {
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
      return;
    }

    setState(() => _isSaving = false);
    final ex = (result as Failure<void>).exception;
    _showSnack(_mapDeleteAccountError(ex), isError: true);
  }

  String _mapDeleteAccountError(Exception ex) {
    if (ex is ValidationException && ex.field == 'password') {
      return AppLocalizations.of(context).validationPasswordRequired;
    }
    if (ex is AuthException) {
      return switch (ex.code) {
        'wrong-password' || 'invalid-credential' => AppLocalizations.of(
          context,
        ).accountSecurityDeleteWrongPassword,
        'requires-recent-login' => AppLocalizations.of(
          context,
        ).accountSecurityDeleteRequiresRecentLogin,
        'too-many-requests' => AppLocalizations.of(
          context,
        ).authErrorTooManyRequests,
        'password-reauth-unavailable' => AppLocalizations.of(
          context,
        ).accountSecurityDeleteReauthUnavailable,
        _ => AppLocalizations.of(context).accountSecurityDeleteGenericError,
      };
    }
    return AppLocalizations.of(context).accountSecurityDeleteGenericError;
  }

  Future<String?> _requestDeletePassword() {
    final controller = TextEditingController();
    bool obscure = true;
    String? error;

    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2230),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: -6,
                    ),
                    BoxShadow(
                      color: AppColors.accentPrimary.withOpacity(0.08),
                      blurRadius: 24,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.error.withOpacity(0.25),
                            AppColors.error.withOpacity(0.12),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.45),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).accountSecurityDeleteTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).accountSecurityDeleteDialogMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: controller,
                      obscureText: obscure,
                      autofocus: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).accountSecurityCurrentPasswordLabel,
                        errorText: error,
                        filled: true,
                        fillColor: AppColors.surfaceGlass.withOpacity(0.6),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setDialogState(() => obscure = !obscure),
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        labelStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.borderSubtle.withOpacity(0.8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.accentPrimary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.error),
                        ),
                      ),
                      onSubmitted: (_) {
                        final value = controller.text.trim();
                        if (value.isEmpty) {
                          setDialogState(
                            () => error = AppLocalizations.of(
                              context,
                            ).validationPasswordRequired,
                          );
                          return;
                        }
                        Navigator.pop(ctx, value);
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.borderSubtle.withOpacity(0.8),
                              ),
                              foregroundColor: AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).dreamDetailDeleteCancel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final value = controller.text.trim();
                              if (value.isEmpty) {
                                setDialogState(
                                  () => error = AppLocalizations.of(
                                    context,
                                  ).validationPasswordRequired,
                                );
                                return;
                              }
                              Navigator.pop(ctx, value);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).accountSecurityDeletePermanently,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirm({required String title, required String message}) =>
      showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.72),
        builder: (ctx) {
          final l = AppLocalizations.of(ctx);
          final isEs = Localizations.localeOf(
            ctx,
          ).languageCode.toLowerCase().startsWith('es');
          final acceptLabel = isEs ? 'Aceptar' : 'Accept';

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2230),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.30),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withOpacity(0.12),
                    blurRadius: 44,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.warning.withOpacity(0.22),
                          AppColors.warning.withOpacity(0.10),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.45),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.warning,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l.dreamDetailDeleteCancel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: AppColors.bgPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(acceptLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  void _showSnack(String msg, {bool isError = false}) {
    final accent = isError ? AppColors.error : AppColors.accentPrimary;
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_rounded;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final l = AppLocalizations.of(context);
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
                  Text(
                    l.settingsAccountSecurity,
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
                  _SubLabel(label: l.accountSecurityCredentialsSection),
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
                          title: Text(
                            l.fieldEmail,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              user != null
                                  ? _maskedEmail(user.email)
                                  : l.accountSecurityNoData,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
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
                          title: Text(
                            l.accountSecurityChangePassword,
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
                  _SubLabel(label: l.accountSecurityPrivacySection),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(
                            Icons.fingerprint,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: Text(
                            l.accountSecurityBiometricTitle,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            _biometricSupported
                                ? l.accountSecurityBiometricSupported
                                : l.accountSecurityBiometricUnsupported,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          value: _biometricEnabled,
                          onChanged: _biometricSupported
                              ? _setBiometricEnabled
                              : null,
                          activeColor: AppColors.accentPrimary,
                        ),
                        _divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: Text(
                            l.accountSecurityDreamVisibility,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ACCIONES DE CUENTA
                  _SubLabel(label: l.accountSecurityAccountActionsSection),
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
                          title: Text(
                            l.profileLogoutButton,
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
                          title: Text(
                            l.accountSecurityDeleteTitle,
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Text(
                      l.accountSecurityPermanentActionsHint,
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
    final l = AppLocalizations.of(context);
    final options = [
      (
        value: 'public',
        icon: Icons.public,
        title: l.accountSecurityVisibilityEveryone,
        subtitle: l.accountSecurityVisibilityEveryoneSubtitle,
      ),
      (
        value: 'followers',
        icon: Icons.group,
        title: l.accountSecurityVisibilityFollowers,
        subtitle: l.accountSecurityVisibilityFollowersSubtitle,
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
            Text(
              l.accountSecurityDreamVisibility,
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
