import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Juice carton with a straw, a fruit circle and a big letter (O / A).
class JuicePainter extends CustomPainter {
  final Color color;
  final Color fruit;
  final String letter;

  JuicePainter({required this.color, required this.fruit, required this.letter});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Straw.
    canvas.drawLine(
      Offset(w * 0.62, h * 0.18),
      Offset(w * 0.78, 0),
      Paint()
        ..color = theme.pink
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    final body = RRect.fromLTRBR(w * 0.18, h * 0.16, w * 0.82, h, const Radius.circular(6));
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(colors: [Color.lerp(color, theme.white, 0.35)!, color, Color.lerp(color, theme.black, 0.2)!])
            .createShader(body.outerRect),
    );
    // Roof fold.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.18, h * 0.2)
        ..lineTo(w * 0.5, h * 0.08)
        ..lineTo(w * 0.82, h * 0.2)
        ..close(),
      Paint()..color = Color.lerp(color, theme.white, 0.5)!,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.2, Paint()..color = fruit);
    canvas.drawCircle(Offset(w * 0.44, h * 0.44), w * 0.06, Paint()..color = theme.white.withValues(alpha: 0.6));
    final tp = TextPainter(
      text: TextSpan(text: letter, style: theme.display(h * 0.22, color: theme.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.5 - tp.width / 2, h * 0.7));
  }

  @override
  bool shouldRepaint(covariant JuicePainter old) => old.color != color || old.letter != letter;
}

/// Triangular golden samsa with sesame dots and a filling tag letter.
class SamsaPainter extends CustomPainter {
  final Color tag;
  final String letter;

  SamsaPainter({required this.tag, required this.letter});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final tri = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..quadraticBezierTo(w * 0.98, h * 0.78, w * 0.92, h * 0.86)
      ..quadraticBezierTo(w * 0.5, h * 0.96, w * 0.08, h * 0.86)
      ..quadraticBezierTo(w * 0.02, h * 0.78, w * 0.5, h * 0.08)
      ..close();
    canvas.drawPath(tri.shift(const Offset(0, 4)), Paint()..color = theme.woodDark.withValues(alpha: 0.4));
    canvas.drawPath(
      tri,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.2),
          colors: [theme.star, theme.orange, theme.wood],
        ).createShader(Offset.zero & size),
    );
    final sesame = Paint()..color = theme.paper;
    for (final o in const [Offset(0.42, 0.42), Offset(0.56, 0.5), Offset(0.47, 0.62), Offset(0.62, 0.68), Offset(0.36, 0.7)]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(w * o.dx, h * o.dy), width: 5, height: 3), sesame);
    }
    // Tag.
    final c = Offset(w * 0.8, h * 0.25);
    canvas.drawCircle(c, w * 0.15, Paint()..color = tag);
    final tp = TextPainter(
      text: TextSpan(text: letter, style: theme.display(w * 0.2, color: theme.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant SamsaPainter old) => old.letter != letter || old.tag != tag;
}
