import 'package:flutter_test/flutter_test.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations_es.dart';
import 'package:hypnos_dreamjournal/shared/utils/validators_formatters.dart';

void main() {
  // Use the Spanish concrete implementation — no widget context needed.
  final l = AppLocalizationsEs();

  // ── validateEmail ──────────────────────────────────────────────────────────

  group('Validators.validateEmail', () {
    test('null → required error', () {
      expect(Validators.validateEmail(null, l), isNotNull);
    });

    test('empty string → required error', () {
      expect(Validators.validateEmail('', l), isNotNull);
    });

    test('missing @ → invalid error', () {
      expect(Validators.validateEmail('notanemail', l), isNotNull);
    });

    test('missing domain → invalid', () {
      expect(Validators.validateEmail('user@', l), isNotNull);
    });

    test('missing TLD → invalid', () {
      expect(Validators.validateEmail('user@domain', l), isNotNull);
    });

    test('valid email → null', () {
      expect(Validators.validateEmail('user@example.com', l), isNull);
    });

    test('email with subdomains → null', () {
      expect(Validators.validateEmail('user@mail.example.co.uk', l), isNull);
    });

    test('email with + alias → null', () {
      expect(Validators.validateEmail('user+tag@example.org', l), isNull);
    });
  });

  // ── validatePassword ───────────────────────────────────────────────────────

  group('Validators.validatePassword', () {
    test('null → required error', () {
      expect(Validators.validatePassword(null, l), isNotNull);
    });

    test('empty string → required error', () {
      expect(Validators.validatePassword('', l), isNotNull);
    });

    test('less than 8 chars → too-short error', () {
      expect(Validators.validatePassword('Abc1', l), isNotNull);
    });

    test('no uppercase → error', () {
      expect(Validators.validatePassword('abcdefg1', l), isNotNull);
    });

    test('no lowercase → error', () {
      expect(Validators.validatePassword('ABCDEFG1', l), isNotNull);
    });

    test('no digit → error', () {
      expect(Validators.validatePassword('Abcdefgh', l), isNotNull);
    });

    test('exactly 8 chars, valid → null', () {
      expect(Validators.validatePassword('Abcdef1!', l), isNull);
    });

    test('long valid password → null', () {
      expect(Validators.validatePassword('SecurePassword123!', l), isNull);
    });
  });

  // ── validateConfirmPassword ────────────────────────────────────────────────

  group('Validators.validateConfirmPassword', () {
    test('null → required error', () {
      expect(
        Validators.validateConfirmPassword(null, 'Password1', l),
        isNotNull,
      );
    });

    test('empty string → required error', () {
      expect(Validators.validateConfirmPassword('', 'Password1', l), isNotNull);
    });

    test('mismatch → error', () {
      expect(
        Validators.validateConfirmPassword('Different1', 'Password1', l),
        isNotNull,
      );
    });

    test('matching passwords → null', () {
      expect(
        Validators.validateConfirmPassword('Password1', 'Password1', l),
        isNull,
      );
    });
  });

  // ── validateDisplayName ────────────────────────────────────────────────────

  group('Validators.validateDisplayName', () {
    test('null → required error', () {
      expect(Validators.validateDisplayName(null, l), isNotNull);
    });

    test('empty string → required error', () {
      expect(Validators.validateDisplayName('', l), isNotNull);
    });

    test('single char → too-short error', () {
      expect(Validators.validateDisplayName('A', l), isNotNull);
    });

    test('exactly 2 chars → null', () {
      expect(Validators.validateDisplayName('Al', l), isNull);
    });

    test('normal name → null', () {
      expect(Validators.validateDisplayName('Luna Soñadora', l), isNull);
    });

    test('51 chars → too-long error', () {
      expect(Validators.validateDisplayName('A' * 51, l), isNotNull);
    });

    test('exactly 50 chars → null', () {
      expect(Validators.validateDisplayName('A' * 50, l), isNull);
    });
  });

  // ── validateRequired ───────────────────────────────────────────────────────

  group('Validators.validateRequired', () {
    test('null → error', () {
      expect(Validators.validateRequired(null, 'Título', l), isNotNull);
    });

    test('empty string → error', () {
      expect(Validators.validateRequired('', 'Título', l), isNotNull);
    });

    test('only whitespace → error', () {
      expect(Validators.validateRequired('   ', 'Título', l), isNotNull);
    });

    test('valid text → null', () {
      expect(
        Validators.validateRequired('Sueño de la madrugada', 'Título', l),
        isNull,
      );
    });
  });

  // ── validateMinLength ──────────────────────────────────────────────────────

  group('Validators.validateMinLength', () {
    test('null → required error', () {
      expect(Validators.validateMinLength(null, 5, l), isNotNull);
    });

    test('empty → required error', () {
      expect(Validators.validateMinLength('', 5, l), isNotNull);
    });

    test('below min → too-short error', () {
      expect(Validators.validateMinLength('abc', 5, l), isNotNull);
    });

    test('exactly at min → null', () {
      expect(Validators.validateMinLength('abcde', 5, l), isNull);
    });

    test('above min → null', () {
      expect(Validators.validateMinLength('abcdef', 5, l), isNull);
    });
  });

  // ── validateMaxLength ──────────────────────────────────────────────────────

  group('Validators.validateMaxLength', () {
    test('null → null (no error)', () {
      expect(Validators.validateMaxLength(null, 10, l), isNull);
    });

    test('below max → null', () {
      expect(Validators.validateMaxLength('abc', 10, l), isNull);
    });

    test('exactly at max → null', () {
      expect(Validators.validateMaxLength('a' * 10, 10, l), isNull);
    });

    test('above max → error', () {
      expect(Validators.validateMaxLength('a' * 11, 10, l), isNotNull);
    });
  });
}
