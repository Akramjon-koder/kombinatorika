import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Front view of a city bus (like the worksheet picture): rounded body, two
/// windscreens, route sign, headlights and bumper. [passenger] draws the
/// trip leader's head behind the windscreen.
class BusPainter extends CustomPainter {
  final Color color;
  final bool passenger;

  BusPainter({required this.color, this.passenger = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = Color.lerp(color, theme.black, 0.3)!;
    // Wheels.
    final wheel = Paint()..color = theme.text;
    canvas.drawRRect(RRect.fromLTRBR(w * 0.1, h * 0.82, w * 0.3, h, const Radius.circular(6)), wheel);
    canvas.drawRRect(RRect.fromLTRBR(w * 0.7, h * 0.82, w * 0.9, h, const Radius.circular(6)), wheel);
    // Body.
    final body = RRect.fromLTRBR(w * 0.04, h * 0.02, w * 0.96, h * 0.9, Radius.circular(w * 0.14));
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(color, theme.white, 0.3)!, color, dark],
          stops: const [0, 0.5, 1],
        ).createShader(body.outerRect),
    );
    // Route sign.
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.3, h * 0.06, w * 0.7, h * 0.14, const Radius.circular(3)),
      Paint()..color = theme.text,
    );
    // Windscreens.
    final glass = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [theme.skyBottom, theme.white, theme.skyTop.withValues(alpha: 0.7)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.5));
    final left = RRect.fromLTRBR(w * 0.1, h * 0.18, w * 0.48, h * 0.5, const Radius.circular(6));
    final right = RRect.fromLTRBR(w * 0.52, h * 0.18, w * 0.9, h * 0.5, const Radius.circular(6));
    canvas.drawRRect(left, glass);
    canvas.drawRRect(right, glass);
    if (passenger) {
      final head = Offset(w * 0.29, h * 0.38);
      canvas.drawCircle(head, w * 0.08, Paint()..color = theme.skin);
      canvas.drawArc(Rect.fromCircle(center: head, radius: w * 0.08), 3.14, 3.14, true, Paint()..color = theme.hair);
      canvas.drawRect(Rect.fromLTWH(head.dx - w * 0.1, head.dy + w * 0.07, w * 0.2, h * 0.06), Paint()..color = theme.violet);
    }
    // Headlights.
    final light = Paint()..color = theme.paper;
    canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.6, w * 0.16, h * 0.1), light);
    canvas.drawOval(Rect.fromLTWH(w * 0.74, h * 0.6, w * 0.16, h * 0.1), light);
    // Grille + bumper.
    canvas.drawRRect(RRect.fromLTRBR(w * 0.36, h * 0.64, w * 0.64, h * 0.7, const Radius.circular(3)), Paint()..color = dark);
    canvas.drawRRect(RRect.fromLTRBR(w * 0.06, h * 0.78, w * 0.94, h * 0.86, const Radius.circular(4)), Paint()..color = theme.text.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(covariant BusPainter old) => old.color != color || old.passenger != passenger;
}
