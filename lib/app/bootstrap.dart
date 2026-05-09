import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hypnos_dreamjournal/firebase_options.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';

class AppBootstrapState {
  const AppBootstrapState({required this.firebaseEnabled, this.warningMessage});

  final bool firebaseEnabled;
  final String? warningMessage;
}

/// Bootstrap function to initialize the app
Future<AppBootstrapState> appBootstrap() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  if (!DefaultFirebaseOptions.isFirebaseConfiguredForCurrentPlatform) {
    final warning =
        'Firebase is not configured for ${DefaultFirebaseOptions.currentPlatformName}. '
        'App will continue in limited mode.';
    debugPrint(warning);
    return AppBootstrapState(firebaseEnabled: false, warningMessage: warning);
  }

  try {
    await FirebaseService.initialize(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return const AppBootstrapState(firebaseEnabled: true);
  } on UnsupportedError catch (e) {
    final warning =
        'Firebase is unsupported on ${DefaultFirebaseOptions.currentPlatformName}: $e';
    debugPrint(warning);
    return AppBootstrapState(firebaseEnabled: false, warningMessage: warning);
  } on FirebaseException catch (e) {
    final warning =
        'Firebase initialization failed (${e.code}) on ${DefaultFirebaseOptions.currentPlatformName}. '
        'App will continue in limited mode.';
    debugPrint(warning);
    return AppBootstrapState(firebaseEnabled: false, warningMessage: warning);
  } catch (e) {
    final warning =
        'Unexpected Firebase startup error on ${DefaultFirebaseOptions.currentPlatformName}: $e';
    debugPrint(warning);
    return AppBootstrapState(firebaseEnabled: false, warningMessage: warning);
  }
}
