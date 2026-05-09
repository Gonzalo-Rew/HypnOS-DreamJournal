import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';

/// Validators for common form validations.
/// Pass [l] (AppLocalizations) to get localised messages.
class Validators {
  /// Validate email
  static String? validateEmail(String? value, AppLocalizations l) {
    if (value == null || value.isEmpty) {
      return l.validationEmailRequired;
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return l.validationEmailInvalid;
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, AppLocalizations l) {
    if (value == null || value.isEmpty) {
      return l.validationPasswordRequired;
    }
    if (value.length < 8) {
      return l.validationPasswordTooShort;
    }
    if (!value.contains(RegExp(r'\p{Lu}', unicode: true))) {
      return l.validationPasswordNoUppercase;
    }
    if (!value.contains(RegExp(r'\p{Ll}', unicode: true))) {
      return l.validationPasswordNoLowercase;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return l.validationPasswordNoDigit;
    }
    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(
    String? value,
    String? password,
    AppLocalizations l,
  ) {
    if (value == null || value.isEmpty) {
      return l.validationConfirmPasswordRequired;
    }
    if (value != password) {
      return l.validationPasswordsMismatch;
    }
    return null;
  }

  /// Validate display name
  static String? validateDisplayName(String? value, AppLocalizations l) {
    if (value == null || value.isEmpty) {
      return l.validationDisplayNameRequired;
    }
    if (value.length < 2) {
      return l.validationDisplayNameTooShort;
    }
    if (value.length > 50) {
      return l.validationDisplayNameTooLong;
    }
    return null;
  }

  /// Validate non-empty field
  static String? validateRequired(
    String? value,
    String fieldName,
    AppLocalizations l,
  ) {
    if (value == null || value.trim().isEmpty) {
      return l.validationFieldRequired(fieldName);
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    AppLocalizations l,
  ) {
    if (value == null || value.isEmpty) {
      return l.validationFieldRequired2;
    }
    if (value.length < minLength) {
      return l.validationFieldTooShort(minLength);
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    AppLocalizations l,
  ) {
    if (value != null && value.length > maxLength) {
      return l.validationFieldTooLong(maxLength);
    }
    return null;
  }
}

/// Formatters for common formatting tasks
class Formatters {
  /// Format duration in seconds to "HH:MM:SS"
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add(hours.toString().padLeft(2, '0'));
    parts.add(minutes.toString().padLeft(2, '0'));
    parts.add(seconds.toString().padLeft(2, '0'));

    return parts.join(':');
  }

  /// Format bytes to human readable size (B, KB, MB, GB)
  static String formatBytes(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int index = 0;

    while (size >= 1024 && index < suffixes.length - 1) {
      size /= 1024;
      index++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }

  /// Format number with thousand separators
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format percentage with 1 decimal place
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}
