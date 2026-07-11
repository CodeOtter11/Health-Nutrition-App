import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWaterGlass extends StatefulWidget {
  final bool filled;

  const AnimatedWaterGlass({
    super.key,
    required this.filled,
  });

  @override
  State<AnimatedWaterGlass> createState() => _AnimatedWaterGlassState();
}

class _AnimatedWaterGlassState extends State<AnimatedWaterGlass>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOut,
    );

    if (widget.filled) _fillController.forward();
  }

  @override
  void didUpdateWidget(AnimatedWaterGlass old) {
    super.didUpdateWidget(old);
    if (widget.filled != old.filled) {
      widget.filled ? _fillController.forward() : _fillController.reverse();
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _waveController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 48,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _fillAnimation,
          _waveController,
          _bubbleController,
        ]),
        builder: (context, _) {
          return CustomPaint(
            painter: _RealisticGlassPainter(
              fillLevel: _fillAnimation.value,
              wavePhase: _waveController.value * 2 * pi,
              bubblePhase: _bubbleController.value,
            ),
          );
        },
      ),
    );
  }
}

class _RealisticGlassPainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;
  final double bubblePhase;

  _RealisticGlassPainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.bubblePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glass shape: slightly tapered (wider at top)
    final topLeft = Offset(0, 2);
    final topRight = Offset(w, 2);
    final bottomLeft = Offset(2, h);
    final bottomRight = Offset(w - 2, h);

    // Glass outline path (trapezoid shape)
    final glassPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    // Clip everything to glass shape
    canvas.save();
    canvas.clipPath(glassPath);

    // ── WATER FILL ──
    if (fillLevel > 0) {
      final waterTop = h - (h - 8) * fillLevel;

      // Wave path
      final wavePath = Path();
      wavePath.moveTo(0, h);
      wavePath.lineTo(bottomLeft.dx, h);
      wavePath.lineTo(bottomLeft.dx, waterTop + 2);

      // Draw wave along the water surface
      const waveAmplitude = 1.5;
      const steps = 30;
      for (int i = 0; i <= steps; i++) {
        final x = (i / steps) * w;
        final y = waterTop +
            sin(wavePhase + (i / steps) * 2 * pi) * waveAmplitude +
            cos(wavePhase * 1.3 + (i / steps) * pi) * waveAmplitude * 0.5;
        wavePath.lineTo(x, y);
      }

      wavePath.lineTo(topRight.dx, waterTop + 2);
      wavePath.lineTo(topRight.dx, h);
      wavePath.close();

      // Water gradient (deep to light)
      final waterPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5BC8F5).withOpacity(0.75),
            const Color(0xFF1A8FD1).withOpacity(0.85),
          ],
        ).createShader(Rect.fromLTWH(0, waterTop, w, h - waterTop));

      canvas.drawPath(wavePath, waterPaint);

      // Water shimmer overlay
      final shimmerPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.transparent,
            Colors.white.withOpacity(0.08),
          ],
        ).createShader(Rect.fromLTWH(0, waterTop, w, h - waterTop));
      canvas.drawPath(wavePath, shimmerPaint);

      // Bubbles inside water
      if (fillLevel > 0.3) {
        _drawBubbles(canvas, w, h, waterTop);
      }
    }

    canvas.restore();

    // ── GLASS BODY ──
    // Outer glass stroke
    final glassPaint = Paint()
      ..color = Colors.blueGrey.shade200.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(glassPath, glassPaint);

    // Inner glass highlight (left edge shine)
    final shineLeft = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.55),
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(1, 2, 4, h * 0.65));
    canvas.drawRect(const Rect.fromLTWH(1, 4, 3, 22), shineLeft);

    // Right edge subtle reflection
    final shineRight = Paint()
      ..color = Colors.white.withOpacity(0.12);
    canvas.drawRect(Rect.fromLTWH(w - 4, 4, 2, h * 0.4), shineRight);

    // Top rim highlight
    final rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(1, 2),
      Offset(w - 1, 2),
      rimPaint,
    );
  }

  void _drawBubbles(Canvas canvas, double w, double h, double waterTop) {
    final rng = Random(42); // fixed seed for stable bubble positions
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int i = 0; i < 4; i++) {
      final bx = 4.0 + rng.nextDouble() * (w - 8);
      final baseY = waterTop + 4 + rng.nextDouble() * (h - waterTop - 8);
      // Each bubble rises at different rate
      final phase = (bubblePhase + i * 0.25) % 1.0;
      final by = baseY - phase * (h - waterTop - 4) * 0.6;
      final radius = 0.8 + rng.nextDouble() * 1.0;

      if (by > waterTop + 1 && by < h - 1) {
        canvas.drawCircle(Offset(bx, by), radius, bubblePaint);
        // Tiny shine on bubble
        canvas.drawCircle(
          Offset(bx - radius * 0.3, by - radius * 0.3),
          radius * 0.25,
          Paint()..color = Colors.white.withOpacity(0.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RealisticGlassPainter old) =>
      old.fillLevel != fillLevel ||
          old.wavePhase != wavePhase ||
          old.bubblePhase != bubblePhase;
}