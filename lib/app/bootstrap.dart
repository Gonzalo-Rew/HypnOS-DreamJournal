import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/data/services/notification_service.dart';
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
    await _initAppCheck();
    await _initGeminiService();
    await _initFcm();
    await _initDailyReminders();
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

Future<void> _initAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.deviceCheck,
    );
  } catch (e) {
    debugPrint('[AppCheck] Init error: $e');
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
    final localNotifications = FlutterLocalNotificationsPlugin();

    // Request permission (iOS; Android 13+ also respects this)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'social_notifications',
            'Social notifications',
            description:
                'Notifications for dream publications and social activity.',
            importance: Importance.defaultImportance,
          ),
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      Future<void> syncCurrentToken() async {
        final token = await messaging.getToken();
        final uid = FirebaseService.getCurrentUserId();
        if (token != null && uid != null) {
          await SocialRepositoryImpl().saveFcmToken(userId: uid, token: token);
        }
      }

      await syncCurrentToken();

      FirebaseService.authStateChanges().listen((user) async {
        if (user != null) {
          await syncCurrentToken();
        }
      });

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

Future<void> _initDailyReminders() async {
  try {
    await NotificationService.instance.initialize();

    final currentUid = FirebaseService.getCurrentUserId();
    if (currentUid != null) {
      await NotificationService.instance.startForUser(currentUid);
    }

    FirebaseService.authStateChanges().listen((user) async {
      if (user == null) {
        await NotificationService.instance.stop();
      } else {
        await NotificationService.instance.startForUser(user.uid);
      }
    });
  } catch (e) {
    debugPrint('[Reminder] Init error: $e');
  }
}
