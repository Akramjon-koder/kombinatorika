import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

/// Road geometry in map fractions: A, station, B and the bend of each road.
const _a = Offset(0.07, 0.5);
const _s = Offset(0.5, 0.5);
const _b = Offset(0.93, 0.5);
const _firstBends = [-0.42, 0.0, 0.42];
const _secondBends = [-0.38, 0.38];

Path _road(Offset from, Offset to, double bend, Size size) {
  final p0 = Offset(from.dx * size.width, from.dy * size.height);
  final p2 = Offset(to.dx * size.width, to.dy * size.height);
  final c = Offset((p0.dx + p2.dx) / 2, size.height * (0.5 + bend * 2));
  return Path()
    ..moveTo(p0.dx, p0.dy)
    ..quadraticBezierTo(c.dx, c.dy, p2.dx, p2.dy);
}

/// Middle point of a road (where its number sign stands).
Offset _mid(Offset from, Offset to, double bend, Size size) {
  final p0 = Offset(from.dx * size.width, from.dy * size.height);
  final p2 = Offset(to.dx * size.width, to.dy * size.height);
  final c = Offset((p0.dx + p2.dx) / 2, size.height * (0.5 + bend * 2));
  return p0 * 0.25 + c * 0.5 + p2 * 0.25;
}

/// Problem 8 — meadow map. Choose a road from A to the station (1, 2, 3) and
/// one from the station to B (4, 5); a little hiker walks the whole route.
class RoutesGame extends StatefulWidget {
  final Problem problem;

  const RoutesGame({super.key, required this.problem});

  @override
  State<RoutesGame> createState() => _RoutesGameState();
}

class _RoutesGameState extends State<RoutesGame> with SingleTickerProviderStateMixin {
  late final AnimationController _walk = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  int? _first;
  int? _second;

  @override
  void dispose() {
    _walk.dispose();
    super.dispose();
  }

  void onTapRoad(int road) {
    if (_walk.isAnimating) return;
    if (road < 3) {
      setState(() {
        _first = road;
        _second = null;
      });
      _walk.value = 0;
      return;
    }
    if (_first == null) {
      context.read<ProblemBloc>().add(const ProblemHintShown(
            'Avval A yalanglikdan bekatgacha yo‘lni tanla (1, 2 yoki 3)!',
          ));
      return;
    }
    setState(() => _second = road - 3);
    _walk.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      final a = _first! + 1, b = _second! + 4;
      context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
            key: 'r$a$b',
            label: '$a → $b',
            emojis: const ['🅰️', '🏕️', '🅱️'],
          )));
      setState(() {
        _first = null;
        _second = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final used = <int>{};
    for (final v in found) {
      used.add(int.parse(v.key[1]) - 1);
      used.add(int.parse(v.key[2]) - 1);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHint(
          text: _first == null
              ? '1-qadam: A dan bekatgacha yo‘lni tanla'
              : _second == null
                  ? '2-qadam: endi bekatdan B gacha yo‘lni tanla (4 yoki 5)'
                  : 'Sayohatchi yo‘lga chiqdi… 🚶',
          color: color,
        ),
        12.height,
        AspectRatio(
          aspectRatio: 2.3,
          child: LayoutBuilder(
            builder: (context, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              final firsts = [for (final b in _firstBends) _road(_a, _s, b, size)];
              final seconds = [for (final b in _secondBends) _road(_s, _b, b, size)];
              final mids = [
                for (final b in _firstBends) _mid(_a, _s, b, size),
                for (final b in _secondBends) _mid(_s, _b, b, size),
              ];
              Widget place(Offset f, Widget child, double box) => Positioned(
                    left: f.dx * size.width - box / 2,
                    top: f.dy * size.height - box / 2,
                    width: box,
                    height: box,
                    child: child,
                  );
              return ClipRRect(
                borderRadius: 24.circular,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _walk,
                        builder: (context, _) => CustomPaint(
                          painter: _MeadowPainter(
                            firsts: firsts,
                            seconds: seconds,
                            first: _first,
                            second: _second,
                            used: used,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    place(_a, const _Glade(label: 'A'), size.height * 0.24),
                    place(_b, const _Glade(label: 'B'), size.height * 0.24),
                    place(_s, const _Station(), size.height * 0.26),
                    for (var r = 0; r < 5; r++)
                      Positioned(
                        left: mids[r].dx - 22,
                        top: mids[r].dy - 22,
                        child: _RoadSign(
                          number: r + 1,
                          selected: r < 3 ? _first == r : _second == r - 3,
                          color: color,
                          onTap: () => onTapRoad(r),
                        ),
                      ),
                    if (_first != null && _second != null)
                      AnimatedBuilder(
                        animation: _walk,
                        builder: (context, _) {
                          final p = _walkerAt(firsts[_first!], seconds[_second!], _walk.value);
                          return Positioned(left: p.dx - 20, top: p.dy - 44, child: const Emoji('🚶', size: 38));
                        },
                      ),
                    // Trees.
                    for (final t in const [Offset(0.2, 0.12), Offset(0.78, 0.9), Offset(0.32, 0.9), Offset(0.66, 0.1)])
                      Positioned(
                        left: t.dx * size.width,
                        top: t.dy * size.height - 16,
                        child: const IgnorePointer(child: Emoji('🌳', size: 28)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Offset _walkerAt(Path first, Path second, double t) {
    final m1 = first.computeMetrics().first;
    final m2 = second.computeMetrics().first;
    final total = m1.length + m2.length;
    final d = t * total;
    final Tangent? tan = d <= m1.length
        ? m1.getTangentForOffset(d)
        : m2.getTangentForOffset(d - m1.length);
    return tan?.position ?? Offset.zero;
  }
}

class _MeadowPainter extends CustomPainter {
  final List<Path> firsts;
  final List<Path> seconds;
  final int? first;
  final int? second;
  final Set<int> used;
  final Color color;

  _MeadowPainter({
    required this.firsts,
    required this.seconds,
    required this.first,
    required this.second,
    required this.used,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(colors: [Color.lerp(theme.grass, theme.white, 0.3)!, theme.grass])
            .createShader(rect),
    );
    void road(Path p, bool selected, bool wasUsed) {
      canvas.drawPath(
        p,
        Paint()
          ..color = theme.woodDark.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        p,
        Paint()
          ..color = selected ? theme.star : theme.road
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round,
      );
      if (wasUsed && !selected) {
        canvas.drawPath(
          p,
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
    }

    for (var i = 0; i < 3; i++) {
      road(firsts[i], first == i, used.contains(i));
    }
    for (var i = 0; i < 2; i++) {
      road(seconds[i], second == i, used.contains(i + 3));
    }
  }

  @override
  bool shouldRepaint(covariant _MeadowPainter old) => true;
}

class _Glade extends StatelessWidget {
  final String label;

  const _Glade({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [Color.lerp(theme.green, theme.white, 0.5)!, theme.green, theme.grassDark],
        ),
        border: Border.all(color: theme.white, width: 3),
        boxShadow: theme.lifted(theme.grassDark, depth: 0.5),
      ),
      child: FittedBox(
        child: Padding(padding: 8.all, child: Text(label, style: theme.display(40, color: theme.white))),
      ),
    );
  }
}

class _Station extends StatelessWidget {
  const _Station();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.orange,
        borderRadius: 10.circular,
        border: Border.all(color: theme.white, width: 3),
        boxShadow: theme.lifted(theme.orange, depth: 0.5),
      ),
      child: const FittedBox(child: Padding(padding: EdgeInsets.all(6), child: Emoji('🏕️', size: 40))),
    );
  }
}

class _RoadSign extends StatelessWidget {
  final int number;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _RoadSign({required this.number, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? theme.star : theme.white,
            shape: BoxShape.circle,
            border: Border.all(color: selected ? theme.orange : color, width: 3),
            boxShadow: theme.lifted(color, depth: 0.4),
          ),
          child: Text('$number', style: theme.display(22, color: theme.text)),
        ),
      ),
    );
  }
}
