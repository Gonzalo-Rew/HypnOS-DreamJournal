import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hypnos_dreamjournal/core/providers/locale_provider.dart';

/// A compact flag+label button that cycles through supported locales.
/// Drop it anywhere: AppBar actions, login screen, profile screen, etc.
class LanguagePickerButton extends StatelessWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context);

    return PopupMenuButton<Locale>(
      tooltip: l.language,
      icon: const Icon(Icons.language),
      onSelected: (locale) => provider.setLocale(locale),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('es'),
          child: Row(
            children: [
              const Text('🇪🇸  '),
              Text(
                l.languageSpanish,
                style: TextStyle(
                  fontWeight: provider.locale.languageCode == 'es'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              const Text('🇬🇧  '),
              Text(
                l.languageEnglish,
                style: TextStyle(
                  fontWeight: provider.locale.languageCode == 'en'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
