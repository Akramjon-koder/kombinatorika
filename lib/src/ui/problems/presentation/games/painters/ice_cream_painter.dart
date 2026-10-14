import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Ice cream: a waffle cone or a cup, a scoop of [flavor] colour and nuts or
/// rainbow sprinkles on top. Any part can be `null` (not chosen yet).
class IceCreamPainter extends CustomPainter {
  /// `true` — waffle cone, `false` — cup, `null` — no container yet.
  final bool? cone;

  /// Scoop colour, `null` — no scoop yet.
  final Color? flavor;

  /// `true` — nuts, `false` — rainbow sprinkles, `null` — none yet.
  final bool? nuts;

  IceCreamPainter({required this.cone, required this.flavor, required this.nuts});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (cone == true) {
      final path = Path()
        ..moveTo(w * 0.2, h * 0.5)
        ..lineTo(w * 0.8, h * 0.5)
        ..lineTo(w * 0.5, h)
        ..close();
      canvas.drawPath(path, Paint()..color = theme.woodLight);
      final grid = Paint()
        ..color = theme.wood
        ..strokeWidth = 1.5;
      canvas.save();
      canvas.clipPath(path);
      for (var i = -4; i < 8; i++) {
        canvas.drawLine(Offset(w * 0.1 * i, h * 0.5), Offset(w * 0.1 * i + w * 0.5, h), grid);
        canvas.drawLine(Offset(w * (1 - 0.1 * i), h * 0.5), Offset(w * (0.5 - 0.1 * i), h), grid);
      }
      canvas.restore();
    } else if (cone == false) {
      final cup = Path()
        ..moveTo(w * 0.14, h * 0.55)
        ..lineTo(w * 0.86, h * 0.55)
        ..lineTo(w * 0.74, h * 0.96)
        ..lineTo(w * 0.26, h * 0.96)
        ..close();
      canvas.drawPath(cup, Paint()..color = theme.pink);
      canvas.drawRect(Rect.fromLTRB(w * 0.18, h * 0.66, w * 0.82, h * 0.72), Paint()..color = theme.white.withValues(alpha: 0.6));
    }
    if (flavor != null) {
      final scoop = Rect.fromCenter(center: Offset(w * 0.5, h * 0.4), width: w * 0.72, height: h * 0.44);
      canvas.drawOval(
        scoop,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [Color.lerp(flavor, theme.white, 0.4)!, flavor!],
          ).createShader(scoop),
      );
      if (nuts != null) {
        const dots = [Offset(0.36, 0.3), Offset(0.52, 0.24), Offset(0.64, 0.34), Offset(0.44, 0.42), Offset(0.6, 0.46), Offset(0.32, 0.46)];
        final rainbow = [theme.red, theme.blue, theme.yellow, theme.greenObj, theme.violet, theme.orange];
        for (var i = 0; i < dots.length; i++) {
          final c = Offset(dots[i].dx * w, dots[i].dy * h);
          if (nuts!) {
            canvas.drawOval(Rect.fromCenter(center: c, width: w * 0.08, height: w * 0.06), Paint()..color = theme.woodDark);
          } else {
            canvas.drawLine(
              c,
              c + Offset(w * 0.06, h * (i.isEven ? 0.02 : -0.02)),
              Paint()
                ..color = rainbow[i]
                ..strokeWidth = w * 0.035
                ..strokeCap = StrokeCap.round,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant IceCreamPainter old) => old.cone != cone || old.flavor != flavor || old.nuts != nuts;
}
