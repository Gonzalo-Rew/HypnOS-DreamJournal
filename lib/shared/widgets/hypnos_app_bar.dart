import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_logo.dart';

/// Standard top bar used across all main screens.
/// Logo "HypnOS" on the left, settings icon on the right.
class HypnosAppBar extends StatelessWidget {
  const HypnosAppBar({super.key, this.onSettingsTap, this.extraActions});

  /// Called when the settings icon is tapped. If null the icon is still shown.
  final VoidCallback? onSettingsTap;

  /// Optional additional action widgets inserted between the spacer and the
  /// settings icon (e.g. language picker).
  final List<Widget>? extraActions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const HypnosGradientLogo(fontSize: 20),
          const Spacer(),
          if (extraActions != null) ...extraActions!,
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            tooltip: 'Ajustes',
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
