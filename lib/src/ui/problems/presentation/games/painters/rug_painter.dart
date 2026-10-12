import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Flat carpet: border band, zig-zag frame, diamond medallion and tassels.
class RugPainter extends CustomPainter {
  final Color color;

  RugPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = Color.lerp(color, theme.black, 0.35)!;
    final light = Color.lerp(color, theme.white, 0.55)!;
    final body = Rect.fromLTWH(8, 0, w - 16, h);
    // Tassels.
    final tassel = Paint()
      ..color = theme.paper
      ..strokeWidth = 2;
    for (double y = 4; y < h - 2; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(8, y), tassel);
      canvas.drawLine(Offset(w - 8, y), Offset(w, y), tassel);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(4)), Paint()..color = color);
    // Border bands.
    final band = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.06;
    canvas.drawRect(body.deflate(h * 0.07), band);
    // Zig-zag.
    final zig = Path();
    final inner = body.deflate(h * 0.17);
    const n = 10;
    zig.moveTo(inner.left, inner.top);
    for (var i = 1; i <= n; i++) {
      zig.lineTo(inner.left + inner.width * i / n, inner.top + (i.isOdd ? h * 0.05 : 0));
    }
    zig.moveTo(inner.left, inner.bottom);
    for (var i = 1; i <= n; i++) {
      zig.lineTo(inner.left + inner.width * i / n, inner.bottom - (i.isOdd ? h * 0.05 : 0));
    }
    canvas.drawPath(
      zig,
      Paint()
        ..color = light
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Medallions.
    for (final f in [0.3, 0.5, 0.7]) {
      final c = Offset(8 + (w - 16) * f, h / 2);
      final r = min(h * 0.22, (w - 16) * 0.08) * (f == 0.5 ? 1.3 : 0.9);
      final d = Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close();
      canvas.drawPath(d, Paint()..color = light);
      canvas.drawCircle(c, r * 0.35, Paint()..color = dark);
    }
  }

  @override
  bool shouldRepaint(covariant RugPainter old) => old.color != color;
}

/// Rolled carpet standing upright: a cylinder with a spiral end on top.
class RolledRugPainter extends CustomPainter {
  final Color color;

  RolledRugPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = Color.lerp(color, theme.black, 0.35)!;
    final light = Color.lerp(color, theme.white, 0.4)!;
    final body = Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(w * 0.3)),
      Paint()
        ..shader = LinearGradient(colors: [dark, color, light, color, dark])
            .createShader(body),
    );
    // Pattern stripes.
    final stripe = Paint()
      ..color = Color.lerp(color, theme.white, 0.6)!.withValues(alpha: 0.7)
      ..strokeWidth = 3;
    for (var i = 1; i < 6; i++) {
      final y = body.top + body.height * i / 6;
      canvas.drawLine(Offset(body.left + 3, y), Offset(body.right - 3, y), stripe);
    }
    // Spiral end.
    final top = Offset(w / 2, h * 0.12);
    canvas.drawOval(
      Rect.fromCenter(center: top, width: w * 0.6, height: w * 0.22),
      Paint()..color = light,
    );
    final spiral = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (var i = 1; i <= 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(center: top, width: w * 0.6 * i / 3.4, height: w * 0.22 * i / 3.4),
        spiral,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RolledRugPainter old) => old.color != color;
}
