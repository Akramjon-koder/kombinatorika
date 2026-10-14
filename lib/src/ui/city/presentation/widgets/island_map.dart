import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/model/student.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../../problems/model/problem.dart';
import 'paper_island.dart';

/// Island centres (fractions of the map) — a serpentine trail 1 → 10.
const List<Offset> _spots = [
  Offset(0.10, 0.27), Offset(0.30, 0.22), Offset(0.50, 0.28), Offset(0.70, 0.22), Offset(0.90, 0.27),
  Offset(0.90, 0.72), Offset(0.70, 0.77), Offset(0.50, 0.71), Offset(0.30, 0.77), Offset(0.10, 0.72),
];

/// Wooden-framed treasure map holding the ten islands (wide screens).
class IslandMap extends StatelessWidget {
  /// Problems of one grade in worksheet order (at most [_spots] islands).
  final List<Problem> problems;

  /// Learner's results by problem id (stars, solved flag).
  final Map<int, ProblemResult> results;

  /// Opens a problem.
  final ValueChanged<Problem> onTap;

  const IslandMap({super.key, required this.problems, required this.results, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.all,
      decoration: BoxDecoration(
        borderRadius: 36.circular,
        gradient: LinearGradient(colors: [theme.woodLight, theme.wood, theme.woodDark]),
        boxShadow: theme.lifted(theme.woodDark, depth: 1.2),
      ),
      child: ClipRRect(
        borderRadius: 24.circular,
        child: AspectRatio(
          aspectRatio: 16 / 8.6,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth, h = c.maxHeight;
              final size = w * 0.16;
              return Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                  // Floating ships / whale decoration.
                  for (final d in const [
                    (Offset(0.2, 0.5), '⛵'),
                    (Offset(0.62, 0.48), '🚢'),
                    (Offset(0.82, 0.5), '🐳'),
                    (Offset(0.4, 0.5), '⛵'),
                    (Offset(0.03, 0.5), '🧭'),
                  ])
                    Positioned(
                      left: d.$1.dx * w,
                      top: d.$1.dy * h - 20,
                      child: Emoji(d.$2, size: w * 0.03),
                    ),
                  for (var i = 0; i < problems.length; i++)
                    Positioned(
                      left: _spots[i].dx * w - size / 2,
                      top: _spots[i].dy * h - size * 0.5,
                      width: size,
                      height: size * 1.15,
                      child: PaperIsland(
                        problem: problems[i],
                        result: results[problems[i].id],
                        onTap: () => onTap(problems[i]),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Parchment, sea waves, compass rose and the dashed trail through the spots.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.9,
          colors: [theme.paper, Color.lerp(theme.paper, theme.woodLight, 0.55)!],
        ).createShader(rect),
    );
    // Waves.
    final wave = Paint()
      ..color = theme.woodDark.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final rnd = Random(3);
    for (var i = 0; i < 46; i++) {
      final o = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h);
      final p = Path()..moveTo(o.dx, o.dy);
      for (var k = 0; k < 3; k++) {
        p.relativeQuadraticBezierTo(7, -6, 14, 0);
      }
      canvas.drawPath(p, wave);
    }
    // Compass rose (bottom-right).
    final c = Offset(w * 0.965, h * 0.5);
    final r = h * 0.07;
    final rose = Paint()..color = theme.woodDark.withValues(alpha: 0.45);
    for (var i = 0; i < 4; i++) {
      final a = i * pi / 2;
      final path = Path()
        ..moveTo(c.dx + cos(a) * r, c.dy + sin(a) * r)
        ..lineTo(c.dx + cos(a + pi / 2) * r * 0.22, c.dy + sin(a + pi / 2) * r * 0.22)
        ..lineTo(c.dx, c.dy)
        ..close();
      canvas.drawPath(path, rose);
    }
    canvas.drawCircle(c, r * 0.75, wave);
    // Dashed trail.
    final trail = Path();
    for (var i = 0; i < _spots.length; i++) {
      final pt = Offset(_spots[i].dx * w, _spots[i].dy * h + h * 0.04);
      if (i == 0) {
        trail.moveTo(pt.dx, pt.dy);
      } else {
        final prev = Offset(_spots[i - 1].dx * w, _spots[i - 1].dy * h + h * 0.04);
        final mid = (prev + pt) / 2 + Offset(i == 5 ? w * 0.06 : 0, i == 5 ? 0 : h * 0.06);
        trail.quadraticBezierTo(mid.dx, mid.dy, pt.dx, pt.dy);
      }
    }
    final dash = Paint()
      ..color = theme.pink.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final m in trail.computeMetrics()) {
      for (double d = 0; d < m.length; d += 18) {
        canvas.drawPath(m.extractPath(d, d + 9), dash);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
