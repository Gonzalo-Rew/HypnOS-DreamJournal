import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/app_routes.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/widgets/flag_language_picker.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_logo.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';

// ─────────────────────────────────────────────
// Welcome Screen
// ─────────────────────────────────────────────
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            // Language picker — top left
            const Positioned(top: 8, left: 16, child: FlagLanguagePicker()),
            // Main layout
            Column(
              children: [
                const SizedBox(height: 52),
                // ── HypnOS gradient logo ──
                const HypnosGradientLogo(fontSize: 34),
                const SizedBox(height: 36),
                // ── Morpheus animated orb ──
                const MorpheusOrb(size: 230),
                const SizedBox(height: 28),
                // ── Morpheus text ──
                Text(
                  l.welcomeMorpheusTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Text(
                    l.welcomeMorpheusSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                const Spacer(),
                // ── CTA area ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Begin Journey → Register
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPrimary,
                            foregroundColor: AppColors.bgPrimary,
                            elevation: 0,
                            shadowColor: AppColors.accentPrimary.withValues(
                              alpha: 0.35,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            l.welcomeBeginJourney,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Already have account
                      Text(
                        l.welcomeAlreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        child: Text(
                          l.welcomeLogIn,
                          style: const TextStyle(
                            color: AppColors.accentPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
                // Bottom tagline
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    l.welcomeTagline,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.35),
                      letterSpacing: 1.8,
                      fontSize: 8.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
