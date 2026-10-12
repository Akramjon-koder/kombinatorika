import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Glossy tea cup with a handle and saucer (side view).
class CupPainter extends CustomPainter {
  final Color color;

  CupPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = Color.lerp(color, theme.black, 0.3)!;
    // Saucer.
    canvas.drawOval(Rect.fromLTWH(w * 0.02, h * 0.82, w * 0.86, h * 0.16), Paint()..color = Color.lerp(color, theme.white, 0.55)!);
    // Handle.
    canvas.drawArc(
      Rect.fromLTWH(w * 0.6, h * 0.3, w * 0.34, h * 0.36),
      -1.4,
      2.8,
      false,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.08,
    );
    // Cup body.
    final body = Path()
      ..moveTo(w * 0.08, h * 0.22)
      ..lineTo(w * 0.76, h * 0.22)
      ..quadraticBezierTo(w * 0.74, h * 0.86, w * 0.42, h * 0.88)
      ..quadraticBezierTo(w * 0.1, h * 0.86, w * 0.08, h * 0.22)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [Color.lerp(color, theme.white, 0.35)!, color, dark]).createShader(Offset.zero & size),
    );
    // Tea surface.
    canvas.drawOval(Rect.fromLTWH(w * 0.08, h * 0.16, w * 0.68, h * 0.14), Paint()..color = dark);
    canvas.drawOval(Rect.fromLTWH(w * 0.12, h * 0.18, w * 0.6, h * 0.1), Paint()..color = theme.wood);
    // Shine.
    canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.38, w * 0.1, h * 0.22), Paint()..color = theme.white.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant CupPainter old) => old.color != color;
}
