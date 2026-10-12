import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/cup_painter.dart';
import 'parts/pick_tile.dart';

/// (name, colour, emoji) of the four cups.
List<(String, Color, String)> get _cups => [
      ('Ko‘k', theme.blue, '🔵'),
      ('Qizil', theme.red, '🔴'),
      ('Sariq', theme.yellow, '🟡'),
      ('Yashil', theme.greenObj, '🟢'),
    ];

/// Cup positions on the table (fractions): top, right, bottom, left.
const _spots = [Offset(0.5, 0.17), Offset(0.84, 0.5), Offset(0.5, 0.83), Offset(0.16, 0.5)];

/// Problem 10 — tea table. Tap two cups: a coloured string connects them.
/// Every string is one way to choose two cups; together they draw the full
/// "handshake" picture of four points (6 lines).
class CupsGame extends StatefulWidget {
  final Problem problem;

  const CupsGame({super.key, required this.problem});

  @override
  State<CupsGame> createState() => _CupsGameState();
}

class _CupsGameState extends State<CupsGame> {
  int? _first;

  void onTapCup(int i) {
    if (_first == null) {
      setState(() => _first = i);
      return;
    }
    if (_first == i) {
      setState(() => _first = null);
      return;
    }
    final a = _first! < i ? _first! : i, b = _first! < i ? i : _first!;
    final cups = _cups;
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'cup$a$b',
          label: '${cups[a].$1} + ${cups[b].$1.toLowerCase()} finjon',
          emojis: [cups[a].$3, cups[b].$3],
        )));
    setState(() => _first = null);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final cups = _cups;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final links = [
      for (final v in found) (int.parse(v.key[3]), int.parse(v.key[4])),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHint(
          text: _first == null
              ? 'Aziz qaysi 2 ta finjonni oladi? Birinchi finjonni bos'
              : '${cups[_first!].$1} finjon tanlandi — endi ikkinchisini bos',
          color: color,
        ),
        12.height,
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth, h = c.maxHeight;
                  final cup = w * 0.2;
                  return Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: _TablePainter(links: links, cups: cups))),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Column(
                            children: [
                              const Emoji('🧒🏻', size: 52),
                              Text('Aziz', style: theme.display(18)),
                            ],
                          ),
                        ),
                      ),
                      const Center(child: IgnorePointer(child: Emoji('🫖', size: 46))),
                      for (var i = 0; i < 4; i++)
                        Positioned(
                          left: _spots[i].dx * w - cup / 2,
                          top: _spots[i].dy * h - cup / 2,
                          width: cup,
                          height: cup,
                          child: GestureDetector(
                            onTap: () => onTapCup(i),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutBack,
                                scale: _first == i ? 1.2 : 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.white.withValues(alpha: _first == i ? 0.9 : 0.55),
                                    border: Border.all(
                                      color: _first == i ? cups[i].$2 : theme.transparent,
                                      width: 4,
                                    ),
                                  ),
                                  padding: (cup * 0.14).all,
                                  child: CustomPaint(painter: CupPainter(cups[i].$2)),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Round wooden table seen from above + the strings between chosen cups.
class _TablePainter extends CustomPainter {
  final List<(int, int)> links;
  final List<(String, Color, String)> cups;

  _TablePainter({required this.links, required this.cups});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = h * 0.47;
    canvas.drawCircle(center + const Offset(0, 10), r, Paint()..color = theme.black.withValues(alpha: 0.15));
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [theme.woodLight, theme.wood],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    // Wood rings.
    final ring = Paint()
      ..color = theme.woodDark.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var k = 1; k <= 4; k++) {
      canvas.drawCircle(center, r * k / 5, ring);
    }
    canvas.drawCircle(center, r * 0.98, Paint()
      ..color = theme.woodDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6);
    // Strings.
    for (final (a, b) in links) {
      final p1 = Offset(_spots[a].dx * w, _spots[a].dy * h);
      final p2 = Offset(_spots[b].dx * w, _spots[b].dy * h);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = theme.white
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..shader = LinearGradient(colors: [cups[a].$2, cups[b].$2]).createShader(Rect.fromPoints(p1, p2))
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TablePainter old) => old.links.length != links.length;
}
