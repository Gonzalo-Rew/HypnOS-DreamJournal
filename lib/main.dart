import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hypnos_dreamjournal/app/app_routes.dart';
import 'package:hypnos_dreamjournal/app/bootstrap.dart';
import 'package:hypnos_dreamjournal/app/main_shell.dart';
import 'package:hypnos_dreamjournal/app/theme/app_theme.dart';
import 'package:hypnos_dreamjournal/core/constants/app_constants.dart';
import 'package:hypnos_dreamjournal/core/providers/locale_provider.dart';
import 'package:hypnos_dreamjournal/features/auth/presentation/auth_gate.dart';
import 'package:hypnos_dreamjournal/features/auth/presentation/login_screen.dart';
import 'package:hypnos_dreamjournal/features/auth/presentation/register_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_form_screen.dart';

Future<void> main() async {
  final bootstrapState = await appBootstrap();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: HypnosApp(bootstrapState: bootstrapState),
    ),
  );
}

class HypnosApp extends StatelessWidget {
  const HypnosApp({
    super.key,
    this.bootstrapState = const AppBootstrapState(firebaseEnabled: true),
  });

  final AppBootstrapState bootstrapState;

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: localeProvider.locale,
      supportedLocales: LocaleProvider.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: bootstrapState.firebaseEnabled
          ? const AuthGate()
          : _FirebaseDisabledScreen(
              warningMessage: bootstrapState.warningMessage,
            ),
      routes: {
        AppRoutes.auth: (context) => const AuthGate(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const MainShell(),
        AppRoutes.newDream: (context) => const DreamFormScreen(),
      },
    );
  }
}

class _FirebaseDisabledScreen extends StatelessWidget {
  const _FirebaseDisabledScreen({this.warningMessage});

  final String? warningMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 56),
              const SizedBox(height: 16),
              Text(
                'Firebase configuration is not available for this platform.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (warningMessage != null) ...[
                const SizedBox(height: 8),
                Text(warningMessage!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
