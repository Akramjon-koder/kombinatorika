import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Glossy party balloon: oval body with a shine, a knot and a wavy string.
class BalloonPainter extends CustomPainter {
  /// Balloon colour.
  final Color color;

  BalloonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = Rect.fromLTWH(w * 0.1, 0, w * 0.8, h * 0.72);
    // String.
    final string = Path()
      ..moveTo(w * 0.5, h * 0.76)
      ..cubicTo(w * 0.36, h * 0.84, w * 0.64, h * 0.9, w * 0.5, h);
    canvas.drawPath(
      string,
      Paint()
        ..color = theme.textMuted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Knot.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.7)
        ..lineTo(w * 0.43, h * 0.78)
        ..lineTo(w * 0.57, h * 0.78)
        ..close(),
      Paint()..color = Color.lerp(color, theme.black, 0.2)!,
    );
    canvas.drawOval(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.9,
          colors: [Color.lerp(color, theme.white, 0.45)!, color, Color.lerp(color, theme.black, 0.22)!],
        ).createShader(body),
    );
    // White balloons need an outline to stand out on white cards.
    canvas.drawOval(
      body,
      Paint()
        ..color = Color.lerp(color, theme.black, 0.25)!.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.28, h * 0.1, w * 0.16, h * 0.14),
      Paint()..color = theme.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant BalloonPainter old) => old.color != color;
}
