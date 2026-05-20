import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/firebase_options.dart';

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
    await _initGeminiService();
    await _initFcm();
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

/// Initialise GeminiService from the build-time key or a runtime-stored key.
Future<void> _initGeminiService() async {
  // No-op: key lives in Firebase Secret Manager, Cloud Functions handle it.
}

/// Initialize Firebase Cloud Messaging and save the token to the user's doc.
Future<void> _initFcm() async {
  try {
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS; Android 13+ also respects this)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await messaging.getToken();
      final uid = FirebaseService.getCurrentUserId();
      if (token != null && uid != null) {
        await SocialRepositoryImpl().saveFcmToken(userId: uid, token: token);
      }

      // Refresh token whenever it rotates
      messaging.onTokenRefresh.listen((newToken) async {
        final currentUid = FirebaseService.getCurrentUserId();
        if (currentUid != null) {
          await SocialRepositoryImpl().saveFcmToken(
            userId: currentUid,
            token: newToken,
          );
        }
      });
    }
  } catch (e) {
    debugPrint('[FCM] Init error: $e');
  }
}
