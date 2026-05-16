// This is a basic Flutter widget test for Hypnos Dream Journal.
//
// TODO: Replace with actual app integration tests after UI screens are implemented.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hypnos_dreamjournal/app/bootstrap.dart';
import 'package:hypnos_dreamjournal/main.dart';

void main() {
  testWidgets('App initializes and shows home page', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const HypnosApp(
        bootstrapState: AppBootstrapState(firebaseEnabled: false),
      ),
    );

    // Verify that the app shows the Hypnos Dream Journal title
    expect(find.text('Hypnos Dream Journal'), findsWidgets);

    // Verify that fallback warning is shown in limited mode
    expect(
      find.text('Firebase configuration is not available for this platform.'),
      findsOneWidget,
    );

    // Verify that the warning icon is displayed in limited mode
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
