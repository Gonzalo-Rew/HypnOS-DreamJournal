import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/core/providers/locale_provider.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';

/// Auth-screen language picker: [flag] [CODE] [▾]
///
/// Shows the current locale as a compact pill. Tapping opens a popup menu
/// with all supported locales. Intended for the Welcome, Login, and
/// Register screens only — other screens keep the icon-based [LanguagePickerButton].
class FlagLanguagePicker extends StatelessWidget {
  const FlagLanguagePicker({super.key});

  static const Map<String, (String, String)> _localeData = {
    'es': ('🇪🇸', 'ES'),
    'en': ('🇬🇧', 'EN'),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context);
    final code = provider.locale.languageCode;
    final current = _localeData[code] ?? ('🌐', code.toUpperCase());

    return PopupMenuButton<Locale>(
      tooltip: l.language,
      offset: const Offset(0, 42),
      color: const Color(0xFF181B2A),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      onSelected: (locale) => provider.setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.$1, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Text(
              current.$2,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 15,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => _localeData.entries.map((entry) {
        final isActive = entry.key == code;
        return PopupMenuItem<Locale>(
          value: Locale(entry.key),
          child: Row(
            children: [
              Text(entry.value.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text(
                entry.value.$2,
                style: TextStyle(
                  color: isActive
                      ? AppColors.accentPrimary
                      : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.accentPrimary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
