import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hypnos_dreamjournal/core/providers/locale_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleProvider – initial state', () {
    test('default locale is Spanish (es)', () {
      final provider = LocaleProvider();
      expect(provider.locale.languageCode, 'es');
    });

    test('supportedLocales contains es and en', () {
      final codes = LocaleProvider.supportedLocales
          .map((l) => l.languageCode)
          .toList();
      expect(codes, containsAll(['es', 'en']));
    });

    test('supportedLocales has exactly 2 entries', () {
      expect(LocaleProvider.supportedLocales.length, 2);
    });
  });

  group('LocaleProvider – setLocale', () {
    test('setLocale changes the locale', () async {
      final provider = LocaleProvider();
      await provider.setLocale(const Locale('en'));
      expect(provider.locale.languageCode, 'en');
    });

    test('setLocale with the same locale does not notify listeners', () async {
      final provider = LocaleProvider(); // starts as 'es'
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setLocale(const Locale('es'));
      expect(notifyCount, 0);
    });

    test('setLocale with a different locale notifies listeners', () async {
      final provider = LocaleProvider();
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setLocale(const Locale('en'));
      expect(notifyCount, greaterThan(0));
    });

    test('setLocale persists to SharedPreferences', () async {
      final provider = LocaleProvider();
      await provider.setLocale(const Locale('en'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'en');
    });
  });

  group('LocaleProvider – loads saved locale on init', () {
    test('picks up previously saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});

      final provider = LocaleProvider();
      // _loadSaved is async — wait a microtask for it to apply
      await Future<void>.delayed(Duration.zero);

      expect(provider.locale.languageCode, 'en');
    });
  });
}
