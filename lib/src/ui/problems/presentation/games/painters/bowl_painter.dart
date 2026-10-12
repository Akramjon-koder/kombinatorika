import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Side view of a porridge bowl with steam; [porridge] colours the filling,
/// [berries] sprinkles red dots on top.
class BowlPainter extends CustomPainter {
  final Color porridge;
  final Color bowl;
  final bool berries;

  BowlPainter({required this.porridge, required this.bowl, this.berries = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Steam.
    final steam = Paint()
      ..color = theme.textHint.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (final x in [0.38, 0.5, 0.62]) {
      final p = Path()
        ..moveTo(w * x, h * 0.32)
        ..quadraticBezierTo(w * (x - 0.06), h * 0.2, w * x, h * 0.12)
        ..quadraticBezierTo(w * (x + 0.06), h * 0.05, w * x, 0);
      canvas.drawPath(p, steam);
    }
    // Filling (ellipse top).
    final rim = Rect.fromLTWH(w * 0.06, h * 0.36, w * 0.88, h * 0.2);
    canvas.drawOval(rim, Paint()..color = porridge);
    canvas.drawOval(
      rim.deflate(4).translate(-w * 0.05, -1),
      Paint()..color = Color.lerp(porridge, theme.white, 0.35)!,
    );
    if (berries) {
      for (final o in [const Offset(0.4, 0.44), const Offset(0.55, 0.42), const Offset(0.62, 0.48)]) {
        canvas.drawCircle(Offset(w * o.dx, h * o.dy), w * 0.04, Paint()..color = theme.red);
      }
    }
    // Bowl body.
    final body = Path()
      ..moveTo(w * 0.04, h * 0.46)
      ..quadraticBezierTo(w * 0.08, h * 0.95, w * 0.5, h * 0.95)
      ..quadraticBezierTo(w * 0.92, h * 0.95, w * 0.96, h * 0.46)
      ..quadraticBezierTo(w * 0.5, h * 0.62, w * 0.04, h * 0.46)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(bowl, theme.white, 0.4)!, bowl, Color.lerp(bowl, theme.black, 0.25)!],
        ).createShader(Offset.zero & size),
    );
    // Rim stripe.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.12, h * 0.66)
        ..quadraticBezierTo(w * 0.5, h * 0.78, w * 0.88, h * 0.66),
      Paint()
        ..color = theme.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant BowlPainter old) =>
      old.porridge != porridge || old.bowl != bowl || old.berries != berries;
}
