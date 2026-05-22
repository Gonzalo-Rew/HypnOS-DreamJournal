import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';

class IntensityUtils {
  IntensityUtils._();

  static int? normalizedScore(int? score) {
    if (score == null) return null;
    return score.clamp(1, 5);
  }

  static String label(AppLocalizations l, int? score) {
    final normalized = normalizedScore(score);
    if (normalized == null) return l.dreamsListMoodUnrated;
    return switch (normalized) {
      1 => l.dreamFormIntensityCalm,
      2 => l.dreamFormIntensityMild,
      3 => l.dreamFormIntensityModerate,
      4 => l.dreamFormIntensityIntense,
      _ => l.dreamFormIntensityExtreme,
    };
  }

  static String upperLabel(AppLocalizations l, int? score) {
    final normalized = normalizedScore(score);
    if (normalized == null) return l.dreamsListMoodUnrated.toUpperCase();
    return label(l, normalized).toUpperCase();
  }

  static Color color(int? score) {
    final normalized = normalizedScore(score);
    if (normalized == null) return AppColors.textSecondary;
    return switch (normalized) {
      1 => AppColors.success,
      2 => AppColors.accentPrimary,
      3 => AppColors.warning,
      4 => const Color(0xFFFF8A65),
      _ => AppColors.error,
    };
  }
}
