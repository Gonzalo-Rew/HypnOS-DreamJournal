import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/app/app_routes.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_form_screen.dart';
import 'package:hypnos_dreamjournal/shared/widgets/language_picker_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = FirebaseService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.homeTitle),
        actions: const [LanguagePickerButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.homeGreeting(
                        user?.displayName ?? user?.email ?? 'Dreamer',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.homeSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const DreamFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: Text(l.homeCreateDream),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.dreams),
              icon: const Icon(Icons.list),
              label: Text(l.homeListDreams),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
              icon: const Icon(Icons.bar_chart),
              label: Text(l.homeDashboard),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.profile),
              icon: const Icon(Icons.person),
              label: Text(l.homeProfile),
            ),
          ],
        ),
      ),
    );
  }
}
