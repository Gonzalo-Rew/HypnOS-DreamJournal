import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';

/// Reusable glassmorphism card — frosted surface with subtle border.
///
/// [accentLeft] draws a 2 px cyan left border (used to highlight the
/// most-recent entry in the diary list).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.accentLeft = false,
    this.borderColor,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final bool accentLeft;
  final Color? borderColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppRadius.md;
    final border = borderColor ?? AppColors.borderSubtle;

    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Stack(
        children: [
          // ── Blur layer (backdrop only, transparent child) ─────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: const SizedBox.expand(),
            ),
          ),
          // ── Content layer on top of blur ──────────────────────────────
          Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(r),
              border: Border.all(color: border),
            ),
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
          // ── Left accent bar (latest entry highlight) ───────────────────
          if (accentLeft)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(r),
                    bottomLeft: Radius.circular(r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
