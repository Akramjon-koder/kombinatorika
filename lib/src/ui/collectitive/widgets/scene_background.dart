import 'dart:math';

import 'package:flutter/material.dart';

import '../../../theme/apptheme.dart';

/// Animated storybook backdrop: sky, sun, drifting clouds, a skyline of
/// colourful toy houses and rolling grass. [tint] shifts the sky so every
/// location of the city has its own mood while staying one world.
class SceneBackground extends StatefulWidget {
  final Color? tint;
  final bool houses;
  final Widget child;

  const SceneBackground({
    super.key,
    required this.child,
    this.tint,
    this.houses = true,
  });

  @override
  State<SceneBackground> createState() => _SceneBackgroundState();
}

class _SceneBackgroundState extends State<SceneBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clouds = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  )..repeat();

  @override
  void dispose() {
    _clouds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _ScenePainter(
              progress: _clouds,
              tint: widget.tint,
              houses: widget.houses,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  final Animation<double> progress;
  final Color? tint;
  final bool houses;

  _ScenePainter({required this.progress, this.tint, required this.houses})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final top = tint == null
        ? theme.skyTop
        : Color.lerp(theme.skyTop, tint, 0.25)!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, theme.skyBottom],
        ).createShader(Offset.zero & size),
    );

    // Sun with soft glow.
    final sun = Offset(w * 0.86, h * 0.12);
    canvas.drawCircle(
      sun,
      90,
      Paint()
        ..shader = RadialGradient(colors: [
          theme.star.withValues(alpha: 0.55),
          theme.star.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: sun, radius: 90)),
    );
    canvas.drawCircle(sun, 34, Paint()..color = theme.star);

    // Drifting clouds.
    final t = progress.value;
    for (var i = 0; i < 5; i++) {
      final speed = 0.6 + (i % 3) * 0.25;
      final x = ((i * 0.23 + t * speed) % 1.2 - 0.1) * w;
      final y = h * (0.08 + (i % 3) * 0.09);
      _cloud(canvas, Offset(x, y), 0.7 + (i % 2) * 0.45);
    }

    // Far hills.
    final hills = Path()..moveTo(0, h * 0.62);
    for (var i = 0; i <= 8; i++) {
      final x = w * i / 8;
      hills.quadraticBezierTo(
        x - w / 16,
        h * (0.52 + (i.isEven ? 0.0 : 0.05)),
        x,
        h * 0.6,
      );
    }
    hills
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hills,
      Paint()..color = Color.lerp(theme.grass, theme.skyBottom, 0.45)!,
    );

    if (houses) _skyline(canvas, size);

    // Front grass.
    final grass = Path()
      ..moveTo(0, h * 0.8)
      ..cubicTo(w * 0.25, h * 0.74, w * 0.6, h * 0.86, w, h * 0.77)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      grass,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.grass, theme.grassDark],
        ).createShader(Rect.fromLTWH(0, h * 0.74, w, h * 0.26)),
    );

    // Little flowers on the grass.
    final rnd = Random(7);
    for (var i = 0; i < 40; i++) {
      final p = Offset(rnd.nextDouble() * w, h * (0.86 + rnd.nextDouble() * 0.13));
      final c = theme.pastel[i % theme.pastel.length];
      for (var k = 0; k < 5; k++) {
        final a = k * 2 * pi / 5;
        canvas.drawCircle(p + Offset(cos(a), sin(a)) * 3.2, 2.6, Paint()..color = c);
      }
      canvas.drawCircle(p, 2, Paint()..color = theme.star);
    }
  }

  void _cloud(Canvas canvas, Offset c, double s) {
    final paint = Paint()..color = theme.white.withValues(alpha: 0.92);
    final shade = Paint()..color = theme.skyBottom.withValues(alpha: 0.9);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, 14 * s), width: 150 * s, height: 30 * s),
      shade,
    );
    for (final o in [
      Offset(-45 * s, 6 * s),
      Offset(-10 * s, -14 * s),
      Offset(30 * s, -4 * s),
      Offset(55 * s, 8 * s),
    ]) {
      canvas.drawCircle(c + o, 30 * s, paint);
    }
  }

  void _skyline(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final base = h * 0.78;
    var x = -20.0;
    var i = 0;
    while (x < w) {
      final bw = 70.0 + (i * 37 % 50);
      final bh = 70.0 + (i * 53 % 90);
      final color = theme.pastel[i % theme.pastel.length];
      final body = Rect.fromLTWH(x, base - bh, bw, bh);
      // Side face for a hint of 3D.
      canvas.drawRect(
        body.translate(8, -6),
        Paint()..color = Color.lerp(color, theme.black, 0.18)!,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, const Radius.circular(4)),
        Paint()..color = color,
      );
      // Roof.
      final roof = Path()
        ..moveTo(x - 6, base - bh)
        ..lineTo(x + bw / 2, base - bh - 34)
        ..lineTo(x + bw + 6, base - bh)
        ..close();
      canvas.drawPath(
        roof,
        Paint()..color = i.isEven ? theme.red.withValues(alpha: 0.85) : theme.primary.withValues(alpha: 0.75),
      );
      // Windows.
      final win = Paint()..color = theme.white.withValues(alpha: 0.85);
      for (var r = 0; r < (bh ~/ 34); r++) {
        for (var c = 0; c < 2; c++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 12 + c * (bw / 2), base - bh + 14 + r * 32, 14, 16),
              const Radius.circular(3),
            ),
            win,
          );
        }
      }
      // Tree between houses.
      if (i % 2 == 1) {
        final tx = x + bw + 10;
        canvas.drawRect(Rect.fromLTWH(tx - 3, base - 24, 6, 24), Paint()..color = theme.woodDark);
        canvas.drawCircle(Offset(tx, base - 34), 18, Paint()..color = theme.grassDark);
        canvas.drawCircle(Offset(tx - 6, base - 40), 10, Paint()..color = theme.grass);
      }
      x += bw + 26;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.tint != tint || old.houses != houses;
}
