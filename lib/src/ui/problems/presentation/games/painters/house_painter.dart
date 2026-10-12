import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Parts of a worksheet house.
enum HousePart { roof, wall, window }

/// Outline house from the worksheet (triangle roof, square wall, small
/// window). Unpainted parts are white with a dark outline; painted parts get
/// a soft gradient so the house looks like a toy block.
class HousePainter extends CustomPainter {
  final Map<HousePart, Color> colors;
  final Color outline;

  HousePainter({required this.colors, required this.outline});

  static Path roofPath(Size s) => Path()
    ..moveTo(s.width * 0.04, s.height * 0.4)
    ..lineTo(s.width * 0.5, s.height * 0.03)
    ..lineTo(s.width * 0.96, s.height * 0.4)
    ..close();

  static Rect wallRect(Size s) => Rect.fromLTRB(s.width * 0.12, s.height * 0.4, s.width * 0.88, s.height * 0.97);

  static Rect windowRect(Size s) => Rect.fromCenter(
        center: Offset(s.width * 0.5, s.height * 0.66),
        width: s.width * 0.26,
        height: s.width * 0.26,
      );

  /// Which part was hit at [p] (window first — it sits on the wall).
  static HousePart? hit(Offset p, Size s) {
    if (windowRect(s).contains(p)) return HousePart.window;
    if (wallRect(s).contains(p)) return HousePart.wall;
    if (roofPath(s).contains(p)) return HousePart.roof;
    return null;
  }

  Paint _fill(HousePart part, Rect bounds) {
    final c = colors[part];
    if (c == null) return Paint()..color = theme.white;
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(c, theme.white, 0.3)!, c],
      ).createShader(bounds);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    final roof = roofPath(size), wall = wallRect(size), win = windowRect(size);
    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.98), width: size.width * 0.9, height: 10),
      Paint()..color = theme.black.withValues(alpha: 0.12),
    );
    canvas.drawRect(wall, _fill(HousePart.wall, wall));
    canvas.drawRect(wall, stroke);
    canvas.drawPath(roof, _fill(HousePart.roof, roof.getBounds()));
    canvas.drawPath(roof, stroke);
    canvas.drawRect(win, _fill(HousePart.window, win));
    canvas.drawRect(win, stroke);
  }

  @override
  bool shouldRepaint(covariant HousePainter old) => true;
}
