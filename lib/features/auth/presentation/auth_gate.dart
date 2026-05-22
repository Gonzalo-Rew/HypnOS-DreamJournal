import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/features/auth/presentation/welcome_screen.dart';
import 'package:hypnos_dreamjournal/app/main_shell.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: FirebaseService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainShell();
        }

        return const WelcomeScreen();
      },
    );
  }
}
