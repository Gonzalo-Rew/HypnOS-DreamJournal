import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';

/// HypnOS gradient logotype with an animated sweeping violet accent.
///
/// Every 6 seconds a violet "shimmer" travels left-to-right across the text
/// over ~2 seconds, then rests before the next sweep.
class HypnosGradientLogo extends StatefulWidget {
  const HypnosGradientLogo({super.key, this.fontSize = 26});

  final double fontSize;

  @override
  State<HypnosGradientLogo> createState() => _HypnosGradientLogoState();
}

class _HypnosGradientLogoState extends State<HypnosGradientLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    // 6 s total: ~2 s sweep (33 %) + ~4 s pause (67 %)
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _anim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 33,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 67),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        // Violet spot travels from off-screen-left (-0.5) to off-screen-right (1.5)
        // so the text is fully cyan when the spot is outside [0, 1].
        final pos = -0.5 + _anim.value * 2.0;
        final s0 = (pos - 0.25).clamp(0.0, 1.0);
        final s1 = pos.clamp(0.0, 1.0);
        final s2 = (pos + 0.25).clamp(0.0, 1.0);

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              AppColors.accentPrimary, // cyan anchor at 0
              AppColors.accentPrimary, // cyan before violet
              Color(0xFF8A2BE2), // violet center
              AppColors.accentPrimary, // cyan after violet
              AppColors.accentPrimary, // cyan anchor at 1
            ],
            stops: [0.0, s0, s1, s2, 1.0],
          ).createShader(bounds),
          child: child!,
        );
      },
      child: Text(
        'HypnOS',
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          color: Colors.white,
        ),
      ),
    );
  }
}
