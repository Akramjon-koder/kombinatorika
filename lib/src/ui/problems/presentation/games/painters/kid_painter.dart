import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Child in a national costume, drawn like a paper doll: a boy wears a
/// do'ppi and a chapon, a girl wears an atlas dress and braids.
class KidPainter extends CustomPainter {
  final bool girl;
  final Color costume;
  final Color accent;

  /// -1…1 — arm swing for the dancing animation.
  final double swing;

  KidPainter({required this.girl, required this.costume, required this.accent, this.swing = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2;
    final skin = Paint()..color = theme.skin;
    final outline = Paint()
      ..color = theme.text.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Legs / boots.
    final boot = Paint()..color = theme.text;
    canvas.drawRRect(RRect.fromLTRBR(cx - w * 0.16, h * 0.84, cx - w * 0.03, h * 0.98, const Radius.circular(4)), boot);
    canvas.drawRRect(RRect.fromLTRBR(cx + w * 0.03, h * 0.84, cx + w * 0.16, h * 0.98, const Radius.circular(4)), boot);

    // Arms.
    final arm = Paint()
      ..color = costume
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;
    final shoulderY = h * 0.42;
    final a = 0.6 + swing * 0.5;
    for (final side in [-1, 1]) {
      final start = Offset(cx + side * w * 0.17, shoulderY);
      final end = start + Offset(side * cos(a) * w * 0.26, -sin(a * side) * h * 0.1 + h * 0.12);
      canvas.drawLine(start, end, arm);
      canvas.drawCircle(end, w * 0.05, skin);
    }

    // Body: dress / chapon (trapezoid).
    final body = Path()
      ..moveTo(cx - w * 0.17, shoulderY - h * 0.03)
      ..lineTo(cx + w * 0.17, shoulderY - h * 0.03)
      ..lineTo(cx + w * (girl ? 0.3 : 0.22), h * 0.86)
      ..lineTo(cx - w * (girl ? 0.3 : 0.22), h * 0.86)
      ..close();
    canvas.drawPath(body, Paint()..color = costume);
    if (girl) {
      // Atlas zig-zag stripes.
      final zig = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      for (var r = 0; r < 4; r++) {
        final y = h * (0.5 + r * 0.09);
        final half = w * (0.18 + r * 0.03);
        final p = Path()..moveTo(cx - half, y);
        for (var k = 1; k <= 6; k++) {
          p.lineTo(cx - half + 2 * half * k / 6, y + (k.isOdd ? -5 : 0));
        }
        canvas.drawPath(p, zig);
      }
    } else {
      // Chapon front opening + belt.
      canvas.drawLine(Offset(cx, shoulderY), Offset(cx, h * 0.86), Paint()
        ..color = accent
        ..strokeWidth = 3);
      canvas.drawRect(Rect.fromLTWH(cx - w * 0.19, h * 0.6, w * 0.38, h * 0.04), Paint()..color = accent);
    }
    canvas.drawPath(body, outline);

    // Head.
    final head = Offset(cx, h * 0.25);
    final r = w * 0.17;
    if (girl) {
      // Braids.
      final braid = Paint()..color = theme.hair;
      for (final side in [-1, 1]) {
        for (var k = 0; k < 4; k++) {
          canvas.drawCircle(Offset(cx + side * r * 0.95, head.dy + r * 0.5 + k * r * 0.45), r * 0.28, braid);
        }
      }
    }
    canvas.drawCircle(head, r, skin);
    canvas.drawCircle(head, r, outline);
    // Hair fringe.
    canvas.drawArc(Rect.fromCircle(center: head, radius: r), pi, pi, true, Paint()..color = theme.hair);
    // Face.
    final eye = Paint()..color = theme.text;
    canvas.drawCircle(head + Offset(-r * 0.38, r * 0.15), r * 0.11, eye);
    canvas.drawCircle(head + Offset(r * 0.38, r * 0.15), r * 0.11, eye);
    canvas.drawArc(
      Rect.fromCenter(center: head + Offset(0, r * 0.35), width: r * 0.7, height: r * 0.5),
      0.2,
      pi - 0.4,
      false,
      Paint()
        ..color = theme.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(head + Offset(-r * 0.6, r * 0.45), r * 0.14, Paint()..color = theme.pink.withValues(alpha: 0.35));
    canvas.drawCircle(head + Offset(r * 0.6, r * 0.45), r * 0.14, Paint()..color = theme.pink.withValues(alpha: 0.35));

    // Hat: do'ppi (boy) / small tiara-scarf (girl).
    if (girl) {
      final scarf = Path()
        ..moveTo(cx - r * 1.05, head.dy - r * 0.2)
        ..quadraticBezierTo(cx, head.dy - r * 1.6, cx + r * 1.05, head.dy - r * 0.2)
        ..quadraticBezierTo(cx, head.dy - r * 0.9, cx - r * 1.05, head.dy - r * 0.2)
        ..close();
      canvas.drawPath(scarf, Paint()..color = accent);
    } else {
      final doppi = Rect.fromLTWH(cx - r * 0.85, head.dy - r * 1.35, r * 1.7, r * 0.75);
      canvas.drawRRect(RRect.fromRectAndCorners(doppi, topLeft: Radius.circular(r * 0.3), topRight: Radius.circular(r * 0.3)), Paint()..color = theme.text);
      final pepper = Paint()..color = theme.white;
      for (final dx in [-0.45, 0.0, 0.45]) {
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + dx * r, doppi.center.dy), width: r * 0.25, height: r * 0.4), pepper);
      }
    }
  }

  @override
  bool shouldRepaint(covariant KidPainter old) =>
      old.swing != swing || old.costume != costume || old.girl != girl;
}
