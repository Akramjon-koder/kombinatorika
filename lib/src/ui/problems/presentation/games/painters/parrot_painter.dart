import 'package:flutter/material.dart';

import '../../../../../theme/apptheme.dart';

/// Colours of one parrot (see the four birds of the worksheet picture).
@immutable
class ParrotLook {
  /// Head colour.
  final Color head;

  /// Back / body colour.
  final Color body;

  /// Chest colour.
  final Color chest;

  /// Wing colour.
  final Color wing;

  /// Tail colour.
  final Color tail;

  /// Beak colour.
  final Color beak;

  /// Crest colour (cockatoo), `null` for no crest.
  final Color? crest;

  /// Long thin tail (quetzal) instead of a wedge tail.
  final bool longTail;

  const ParrotLook({
    required this.head,
    required this.body,
    required this.chest,
    required this.wing,
    required this.tail,
    required this.beak,
    this.crest,
    this.longTail = false,
  });
}

/// A parrot sitting on a branch, facing right.
class ParrotPainter extends CustomPainter {
  /// Colours of the bird.
  final ParrotLook look;

  ParrotPainter(this.look);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Paint fill(Color c) => Paint()..color = c;
    // Tail.
    final tail = Path()
      ..moveTo(w * 0.36, h * 0.6)
      ..lineTo(look.longTail ? w * 0.3 : w * 0.24, h)
      ..lineTo(look.longTail ? w * 0.42 : w * 0.46, h)
      ..lineTo(w * 0.54, h * 0.62)
      ..close();
    canvas.drawPath(tail, fill(look.tail));
    // Branch.
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.06, h * 0.7, w * 0.94, h * 0.76, Radius.circular(h * 0.03)),
      fill(theme.wood),
    );
    // Body and chest.
    final body = Rect.fromLTRB(w * 0.28, h * 0.28, w * 0.7, h * 0.74);
    canvas.drawOval(body, fill(look.body));
    canvas.drawOval(Rect.fromLTRB(w * 0.46, h * 0.34, w * 0.7, h * 0.7), fill(look.chest));
    // Wing.
    canvas.save();
    canvas.translate(w * 0.42, h * 0.5);
    canvas.rotate(0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.2, height: h * 0.34), fill(look.wing));
    canvas.restore();
    // Crest.
    if (look.crest != null) {
      final crest = Path()
        ..moveTo(w * 0.46, h * 0.16)
        ..lineTo(w * 0.36, h * 0.0)
        ..lineTo(w * 0.52, h * 0.1)
        ..lineTo(w * 0.5, h * -0.02)
        ..lineTo(w * 0.6, h * 0.12)
        ..close();
      canvas.drawPath(crest, fill(look.crest!));
    }
    // Head.
    final head = Offset(w * 0.58, h * 0.26);
    canvas.drawCircle(head, w * 0.16, fill(look.head));
    // Beak.
    final beak = Path()
      ..moveTo(w * 0.7, h * 0.2)
      ..quadraticBezierTo(w * 0.86, h * 0.22, w * 0.8, h * 0.36)
      ..lineTo(w * 0.7, h * 0.32)
      ..close();
    canvas.drawPath(beak, fill(look.beak));
    // Eye.
    canvas.drawCircle(head + Offset(w * 0.04, -h * 0.02), w * 0.045, fill(theme.white));
    canvas.drawCircle(head + Offset(w * 0.05, -h * 0.02), w * 0.025, fill(theme.text));
    // Feet.
    canvas.drawCircle(Offset(w * 0.46, h * 0.73), w * 0.03, fill(theme.grey));
    canvas.drawCircle(Offset(w * 0.56, h * 0.73), w * 0.03, fill(theme.grey));
  }

  @override
  bool shouldRepaint(covariant ParrotPainter old) => old.look != look;
}
