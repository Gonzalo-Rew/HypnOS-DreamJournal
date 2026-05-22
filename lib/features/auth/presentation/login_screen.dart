import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/app_routes.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/core/config/app_settings.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/utils/biometric_auth_service.dart';
import 'package:hypnos_dreamjournal/shared/utils/auth_error_localizer.dart';
import 'package:hypnos_dreamjournal/shared/utils/validators_formatters.dart';
import 'package:hypnos_dreamjournal/shared/widgets/flag_language_picker.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepositoryImpl();
  final BiometricAuthService _biometricAuthService =
      BiometricAuthService.instance;
  bool _isLoading = false;
  bool _isBiometricLoading = true;
  bool _isBiometricAuthenticating = false;
  bool _showBiometricLogin = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBiometricLoginState();
  }

  Future<void> _loadBiometricLoginState() async {
    final enabled = await AppSettings.instance.getBiometricEnabled();
    final hasCredentials = await _biometricAuthService.hasCredentials();
    final supported = await _biometricAuthService.isAvailable();
    if (!mounted) return;
    setState(() {
      _showBiometricLogin = enabled && hasCredentials && supported;
      _isBiometricLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepository.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _isLoading = false;
      if (result is Failure<void>) {
        final ex = result.exception;
        _errorMessage = ex is AuthException
            ? localizeAuthError(l, ex.code)
            : l.authErrorGeneric;
      }
    });

    if (result is Success<void>) {
      await _saveBiometricCredentialsIfEnabled();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  Future<void> _saveBiometricCredentialsIfEnabled() async {
    final enabled = await AppSettings.instance.getBiometricEnabled();
    if (!enabled) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    await _biometricAuthService.saveCredentials(
      email: email,
      password: password,
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _authRepository.signInWithGoogle();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _isLoading = false;
      if (result is Failure<void>) {
        final ex = result.exception;
        _errorMessage = ex is AuthException
            ? localizeAuthError(l, ex.code)
            : l.authErrorGeneric;
      }
    });
    if (result is Success<void>) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _authRepository.signInWithApple();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _isLoading = false;
      if (result is Failure<void>) {
        final ex = result.exception;
        _errorMessage = ex is AuthException
            ? localizeAuthError(l, ex.code)
            : l.authErrorGeneric;
      }
    });
    if (result is Success<void>) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  Future<void> _signInWithBiometrics() async {
    if (_isLoading || _isBiometricAuthenticating) return;
    setState(() {
      _isBiometricAuthenticating = true;
      _errorMessage = null;
    });

    final authenticated = await _biometricAuthService.authenticate(
      localizedReason: 'Confirma tu huella para iniciar sesión',
    );

    if (!mounted) return;
    if (!authenticated) {
      setState(() => _isBiometricAuthenticating = false);
      return;
    }

    final credentials = await _biometricAuthService.getCredentials();
    if (credentials == null) {
      setState(() {
        _isBiometricAuthenticating = false;
        _errorMessage = 'No hay credenciales biométricas guardadas.';
      });
      return;
    }

    final result = await _authRepository.signIn(
      email: credentials.email,
      password: credentials.password,
    );

    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _isBiometricAuthenticating = false;
      if (result is Failure<void>) {
        final ex = result.exception;
        _errorMessage = ex is AuthException
            ? localizeAuthError(l, ex.code)
            : l.authErrorGeneric;
      }
    });

    if (result is Success<void>) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final l = AppLocalizations.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = l.validationEmailRequired);
      return;
    }

    if (Validators.validateEmail(email, l) != null) {
      setState(() => _errorMessage = l.validationEmailInvalid);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withValues(alpha: 0.12),
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
                      AppColors.accentPrimary.withValues(alpha: 0.20),
                      AppColors.accentSecondary.withValues(alpha: 0.20),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.45),
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
              const Text(
                'Restablecer contraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Te enviaremos un enlace de recuperación a:\n$email',
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
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPrimary,
                        foregroundColor: AppColors.bgPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Enviar enlace',
                        style: TextStyle(fontWeight: FontWeight.w700),
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

    final result = await _authRepository.sendPasswordResetEmail(email: email);
    if (!mounted) return;

    if (result is Success<void>) {
      setState(() => _errorMessage = null);
      await _showEmailSentDialog(email);
      return;
    }

    final ex = (result as Failure<void>).exception;
    setState(() {
      _errorMessage = ex is AuthException
          ? localizeAuthError(l, ex.code)
          : l.authErrorGeneric;
    });
  }

  Future<void> _showEmailSentDialog(String email) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withValues(alpha: 0.12),
                blurRadius: 48,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentPrimary.withValues(alpha: 0.18),
                      AppColors.accentSecondary.withValues(alpha: 0.18),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.45),
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.accentPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const HypnosGradientLogo(fontSize: 22),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: FlagLanguagePicker(),
                  ),
                ],
              ),
            ),
            // ── Scrollable body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.loginPortalTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.loginPortalSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── Glassmorphism form card ──────────────────────────
                    _LoginCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PortalField(
                              label: 'EMAIL',
                              hint: 'consciousness@hypnos.io',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => Validators.validateEmail(v, l),
                            ),
                            const SizedBox(height: 18),
                            _PortalField(
                              label: 'PASSWORD',
                              hint: '••••••••',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (v) => Validators.validateRequired(
                                v,
                                l.fieldPassword,
                                l,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),
                            ),
                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : _sendPasswordReset,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(top: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  l.loginForgotPassword,
                                  style: const TextStyle(
                                    color: AppColors.accentPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            // Sign in button
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentPrimary,
                                  foregroundColor: AppColors.bgPrimary,
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.bgPrimary,
                                        ),
                                      )
                                    : Text(
                                        l.loginSignIn,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                            if (_isBiometricLoading || _showBiometricLogin) ...[
                              const SizedBox(height: 12),
                              if (_showBiometricLogin)
                                TextButton.icon(
                                  onPressed:
                                      _isLoading || _isBiometricAuthenticating
                                      ? null
                                      : _signInWithBiometrics,
                                  icon: _isBiometricAuthenticating
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.accentPrimary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.fingerprint,
                                          color: AppColors.accentPrimary,
                                        ),
                                  label: const Text(
                                    'Entrar con huella',
                                    style: TextStyle(
                                      color: AppColors.accentPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                            ],
                            const SizedBox(height: 24),
                            _OrDivider(label: l.registerOrSecureAccess),
                            const SizedBox(height: 16),
                            _SocialButton(
                              onTap: _isLoading ? null : _signInWithApple,
                              label: l.registerContinueApple,
                              icon: Icons.apple,
                            ),
                            const SizedBox(height: 10),
                            _SocialButton(
                              onTap: _isLoading ? null : _signInWithGoogle,
                              label: l.registerContinueGoogle,
                              icon: Icons.g_mobiledata_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Create account link
                    Center(
                      child: Column(
                        children: [
                          Text(
                            l.loginNoAccount,
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.70,
                              ),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
                            ),
                            child: Text(
                              l.welcomeBeginJourney,
                              style: const TextStyle(
                                color: AppColors.accentPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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

// ─── Glassmorphism card ────────────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Labeled field ─────────────────────────────────────────────────────────
class _PortalField extends StatelessWidget {
  const _PortalField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.28),
              fontSize: 14,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accentPrimary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── OR divider ────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderSubtle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderSubtle)),
      ],
    );
  }
}

// ─── Social button ─────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.label,
    required this.icon,
  });

  final VoidCallback? onTap;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
