import 'package:flutter_test/flutter_test.dart';
import 'package:hypnos_dreamjournal/shared/utils/validators_formatters.dart';

void main() {
  // ── formatDuration ─────────────────────────────────────────────────────────

  group('Formatters.formatDuration', () {
    test('0 seconds → "00:00"', () {
      expect(Formatters.formatDuration(0), '00:00');
    });

    test('59 seconds → "00:59"', () {
      expect(Formatters.formatDuration(59), '00:59');
    });

    test('60 seconds → "01:00"', () {
      expect(Formatters.formatDuration(60), '01:00');
    });

    test('90 seconds → "01:30"', () {
      expect(Formatters.formatDuration(90), '01:30');
    });

    test('3600 seconds (1 hour) → "01:00:00"', () {
      expect(Formatters.formatDuration(3600), '01:00:00');
    });

    test('3661 seconds → "01:01:01"', () {
      expect(Formatters.formatDuration(3661), '01:01:01');
    });

    test('7200 seconds (2 hours) → "02:00:00"', () {
      expect(Formatters.formatDuration(7200), '02:00:00');
    });

    test('3599 seconds → "59:59"', () {
      expect(Formatters.formatDuration(3599), '59:59');
    });
  });

  // ── formatBytes ────────────────────────────────────────────────────────────

  group('Formatters.formatBytes', () {
    test('0 bytes → "0.00 B"', () {
      expect(Formatters.formatBytes(0), '0.00 B');
    });

    test('1024 bytes → "1.00 KB"', () {
      expect(Formatters.formatBytes(1024), '1.00 KB');
    });

    test('1024 * 1024 → "1.00 MB"', () {
      expect(Formatters.formatBytes(1024 * 1024), '1.00 MB');
    });

    test('1024 * 1024 * 1024 → "1.00 GB"', () {
      expect(Formatters.formatBytes(1024 * 1024 * 1024), '1.00 GB');
    });

    test('512 bytes → "512.00 B"', () {
      expect(Formatters.formatBytes(512), '512.00 B');
    });

    test('1536 bytes → "1.50 KB"', () {
      expect(Formatters.formatBytes(1536), '1.50 KB');
    });
  });

  // ── formatNumber ───────────────────────────────────────────────────────────

  group('Formatters.formatNumber', () {
    test('0 → "0"', () => expect(Formatters.formatNumber(0), '0'));
    test('999 → "999"', () => expect(Formatters.formatNumber(999), '999'));
    test(
      '1000 → "1,000"',
      () => expect(Formatters.formatNumber(1000), '1,000'),
    );
    test('1000000 → "1,000,000"', () {
      expect(Formatters.formatNumber(1000000), '1,000,000');
    });
    test('42 → "42"', () => expect(Formatters.formatNumber(42), '42'));
  });

  // ── formatPercentage ───────────────────────────────────────────────────────

  group('Formatters.formatPercentage', () {
    test('0.0 → "0.0%"', () {
      expect(Formatters.formatPercentage(0.0), '0.0%');
    });

    test('1.0 → "100.0%"', () {
      expect(Formatters.formatPercentage(1.0), '100.0%');
    });

    test('0.5 → "50.0%"', () {
      expect(Formatters.formatPercentage(0.5), '50.0%');
    });

    test('0.333 → "33.3%"', () {
      expect(Formatters.formatPercentage(0.333), '33.3%');
    });

    test('0.756 → "75.6%"', () {
      expect(Formatters.formatPercentage(0.756), '75.6%');
    });
  });
}
