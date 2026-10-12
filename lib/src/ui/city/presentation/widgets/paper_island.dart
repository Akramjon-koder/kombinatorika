import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/model/student.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../../collectitive/widgets/student_chip.dart';
import '../../../problems/model/problem.dart';

/// Decoration emojis scattered on each island, by problem kind.
const Map<ProblemKind, List<String>> _decor = {
  ProblemKind.canteen: ['🍳', '🌭', '🥗'],
  ProblemKind.insectCards: ['🐞', '🪲', '🌼'],
  ProblemKind.carpets: ['🧵', '🏺', '✨'],
  ProblemKind.breakfast: ['🍵', '🥛', '🍓'],
  ProblemKind.houses: ['🎨', '🖌️', '🏡'],
  ProblemKind.dancers: ['🪘', '🎶', '🌸'],
  ProblemKind.buses: ['🚏', '🚍', '🌳'],
  ProblemKind.routes: ['🌲', '🚩', '🌳'],
  ProblemKind.picnic: ['🥟', '🍊', '🍎'],
  ProblemKind.cups: ['🫖', '🍪', '🌿'],
};

/// Paper-cut 3D island: several wavy layers stacked with an offset (like the
/// islands in `examplee.jpg`), a little scene of emojis on top, a number flag
/// and the place name. Lifts on hover.
class PaperIsland extends StatefulWidget {
  final Problem problem;
  final ProblemResult? result;
  final VoidCallback onTap;

  const PaperIsland({super.key, required this.problem, required this.result, required this.onTap});

  @override
  State<PaperIsland> createState() => _PaperIslandState();
}

class _PaperIslandState extends State<PaperIsland> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.problem;
    final decor = _decor[p.kind]!;
    final solved = widget.result?.solved ?? false;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: Offset(0, _hover ? -0.04 : 0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _hover ? 1.06 : 1,
            child: LayoutBuilder(
              builder: (context, c) {
                final s = c.maxWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Layers.
                    Positioned(
                      top: s * 0.12,
                      left: 0,
                      right: 0,
                      height: s * 0.72,
                      child: CustomPaint(
                        painter: _IslandPainter(color: p.color, seed: p.id, glow: _hover),
                      ),
                    ),
                    // Scene on top.
                    Positioned(
                      top: s * 0.02,
                      left: 0,
                      right: 0,
                      height: s * 0.6,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(left: s * 0.12, bottom: s * 0.06, child: Emoji(decor[0], size: s * 0.15)),
                          Positioned(right: s * 0.1, bottom: s * 0.1, child: Emoji(decor[1], size: s * 0.15)),
                          Positioned(right: s * 0.26, top: s * 0.02, child: Emoji(decor[2], size: s * 0.12)),
                          Emoji(p.emoji, size: s * 0.34),
                        ],
                      ),
                    ),
                    // Number flag.
                    Positioned(
                      left: s * 0.04,
                      top: s * 0.04,
                      child: Container(
                        width: s * 0.2,
                        height: s * 0.2,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: solved ? theme.green : theme.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: solved ? theme.white : p.color, width: 3),
                          boxShadow: theme.lifted(p.color, depth: 0.3),
                        ),
                        child: solved
                            ? Icon(Icons.check_rounded, color: theme.white, size: s * 0.13)
                            : Text('${p.id}', style: theme.display(s * 0.11, color: p.color)),
                      ),
                    ),
                    // Name ribbon.
                    Positioned(
                      top: s * 0.74,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.paper,
                              borderRadius: 14.circular,
                              border: Border.all(color: theme.woodDark.withValues(alpha: 0.5), width: 2),
                              boxShadow: theme.lifted(theme.woodDark, depth: 0.3),
                            ),
                            child: Text(
                              p.place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.display(max(14, s * 0.095), color: theme.text),
                            ),
                          ),
                          4.height,
                          StarRow(stars: widget.result?.stars ?? 0, size: max(16, s * 0.1)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Stacked wavy "paper" layers, darkest at the bottom.
class _IslandPainter extends CustomPainter {
  final Color color;
  final int seed;
  final bool glow;

  _IslandPainter({required this.color, required this.seed, required this.glow});

  Path _blob(Rect r, int salt) {
    final path = Path();
    final rnd = Random(seed * 31 + salt);
    final phases = List.generate(3, (_) => rnd.nextDouble() * pi * 2);
    const steps = 60;
    for (var i = 0; i <= steps; i++) {
      final a = i / steps * 2 * pi;
      final k = 1 +
          0.06 * sin(a * 3 + phases[0]) +
          0.04 * sin(a * 5 + phases[1]) +
          0.025 * sin(a * 9 + phases[2]);
      final pt = Offset(
        r.center.dx + cos(a) * r.width / 2 * k,
        r.center.dy + sin(a) * r.height / 2 * k,
      );
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.86), width: w * 0.95, height: h * 0.3),
      Paint()
        ..color = theme.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    if (glow) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w / 2, h * 0.5), width: w * 1.05, height: h * 0.9),
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
    }
    const layers = 5;
    for (var i = 0; i < layers; i++) {
      final t = i / (layers - 1);
      final layerColor = Color.lerp(
        Color.lerp(color, theme.black, 0.35),
        Color.lerp(color, theme.white, 0.45),
        t,
      )!;
      final inset = w * 0.035 * i;
      final rect = Rect.fromLTRB(inset, h * 0.2 - i * h * 0.035, w - inset, h * 0.8 - i * h * 0.035);
      final path = _blob(rect, i);
      canvas.drawPath(
        path.shift(const Offset(0, 3)),
        Paint()..color = theme.black.withValues(alpha: 0.12),
      );
      canvas.drawPath(path, Paint()..color = layerColor);
    }
    // Grass top highlight.
    final top = Rect.fromLTRB(w * 0.17, h * 0.06, w * 0.83, h * 0.66);
    canvas.drawPath(
      _blob(top, 99),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [theme.white.withValues(alpha: 0.55), theme.white.withValues(alpha: 0)],
        ).createShader(top),
    );
  }

  @override
  bool shouldRepaint(covariant _IslandPainter old) =>
      old.color != color || old.glow != glow;
}
