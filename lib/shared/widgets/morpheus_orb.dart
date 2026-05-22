import 'dart:math';
import 'package:flutter/material.dart';

/// Morpheus animated orb — visual identity of HypnOS.
///
/// All three animation tracks run independent sine-wave loops so the orb
/// always returns to exactly the same state at the end of each cycle:
///
///   • rotate  — full 360° every 9 s (bands spin at different speeds)
///   • float   — sin-wave offset ±9 px, period 4 s
///   • pulse   — sin-wave scale 0.97–1.03, period 5 s
///
/// Use [size] to scale the orb to any diameter.
class MorpheusOrb extends StatefulWidget {
  const MorpheusOrb({
    super.key,
    this.size = 220,
    this.showBlueGlow = true,
  });
  final double size;
  final bool showBlueGlow;

  @override
  State<MorpheusOrb> createState() => _MorpheusOrbState();
}

class _MorpheusOrbState extends State<MorpheusOrb>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotateCtrl, _floatCtrl, _pulseCtrl]),
      builder: (_, child) {
        final rotateAngle = _rotateCtrl.value * 2 * pi;
        final floatOffset = sin(_floatCtrl.value * 2 * pi) * 9.0;
        final pulseScale = 1.0 + sin(_pulseCtrl.value * 2 * pi) * 0.03;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: pulseScale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: MorpheusOrbPainter(
                  rotateAngle,
                  showBlueGlow: widget.showBlueGlow,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Static snapshot of the orb at a fixed [rotation] angle.
/// Useful for small avatar badges where animation controllers would waste
/// resources or where movement inside a tight clip looks odd.
class MorpheusOrbStatic extends StatelessWidget {
  const MorpheusOrbStatic({
    super.key,
    this.size = 42,
    this.rotation = 0.8,
    this.showBlueGlow = true,
  });
  final double size;
  final double rotation;
  final bool showBlueGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MorpheusOrbPainter(rotation, showBlueGlow: showBlueGlow),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter (public so screens can embed a static version inside ClipOval, etc.)
// ─────────────────────────────────────────────────────────────────────────────
class MorpheusOrbPainter extends CustomPainter {
  const MorpheusOrbPainter(this.rotation, {this.showBlueGlow = true});
  final double rotation;
  final bool showBlueGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final r = size.width * 0.42;

    // 1. Outer ambient glow
    canvas.drawCircle(
      center,
      r * 1.55,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45)
        ..color = const Color(0xFF8A2BE2).withValues(alpha: 0.38),
    );
    if (showBlueGlow) {
      canvas.drawCircle(
        center,
        r * 1.20,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22)
          ..color = const Color(0xFF00F5FF).withValues(alpha: 0.18),
      );
    }

    // 2. Clip everything to sphere boundary
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: r)),
    );

    // 3. Base radial gradient (cyan core → violet mid → deep purple rim)
    canvas.drawRect(
      Rect.fromCenter(center: center, width: r * 2.2, height: r * 2.2),
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.30),
          radius: 1.05,
          colors: [
            Color(0xFF5AE8FF),
            Color(0xFF7B68EE),
            Color(0xFF5B1DAE),
            Color(0xFF100520),
          ],
          stops: [0.0, 0.30, 0.62, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // 4. Twisted elliptical bands (each at a different rotation speed)
    const bandDefs = [
      _BandDef(
        color: Color(0xFF00F5FF),
        alpha: 0.65,
        widthFactor: 1.90,
        heightFactor: 0.52,
        speedFactor: 1.00,
        blur: 2,
      ),
      _BandDef(
        color: Color(0xFFB080FF),
        alpha: 0.55,
        widthFactor: 2.05,
        heightFactor: 0.40,
        speedFactor: -0.65,
        blur: 2,
      ),
      _BandDef(
        color: Color(0xFF40C8FF),
        alpha: 0.45,
        widthFactor: 1.70,
        heightFactor: 0.62,
        speedFactor: 0.45,
        blur: 1,
      ),
    ];

    for (final band in bandDefs) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation * band.speedFactor);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: r * band.widthFactor,
          height: r * band.heightFactor,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.13
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, band.blur.toDouble())
          ..color = band.color.withValues(alpha: band.alpha),
      );
      canvas.restore();
    }

    // 5. Inner cyan core glow
    canvas.drawCircle(
      center,
      r * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF80F0FF).withValues(alpha: 0.70),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.42)),
    );

    // 6. Specular highlight (upper-left)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.25, cy - r * 0.30),
        width: r * 0.72,
        height: r * 0.46,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.52),
                Colors.white.withValues(alpha: 0.12),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx - r * 0.25, cy - r * 0.30),
                width: r * 0.72,
                height: r * 0.46,
              ),
            ),
    );

    canvas.restore(); // end sphere clip

    // 7. Bottom diffuse reflection
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 1.15),
        width: r * 1.10,
        height: r * 0.15,
      ),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = const Color(0xFF8A2BE2).withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(MorpheusOrbPainter old) => old.rotation != rotation;
}

class _BandDef {
  const _BandDef({
    required this.color,
    required this.alpha,
    required this.widthFactor,
    required this.heightFactor,
    required this.speedFactor,
    required this.blur,
  });

  final Color color;
  final double alpha;
  final double widthFactor;
  final double heightFactor;
  final double speedFactor;
  final int blur;
}
