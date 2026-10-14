import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

/// Village and lake ends of every trail (fractions of the map).
const _village = Offset(0.17, 0.52);

/// Lake end of every trail.
const _lake = Offset(0.8, 0.5);

/// Bézier control points of the three trails: top, middle, bottom.
const _controls = [Offset(0.49, -0.22), Offset(0.49, 0.51), Offset(0.49, 1.24)];

/// Point of trail [i] at [t] (0 = village, 1 = lake) on a [size] map.
Offset _trailPoint(int i, double t, Size size) {
  final c = _controls[i];
  final u = 1 - t;
  final x = u * u * _village.dx + 2 * u * t * c.dx + t * t * _lake.dx;
  final y = u * u * _village.dy + 2 * u * t * c.dy + t * t * _lake.dy;
  return Offset(x * size.width, y * size.height);
}

/// 4th grade problem 1 — lake trails. Tap the trail to walk to the lake, then
/// a different trail to come back: Abdulmalik walks the whole trip. The
/// "go × return" table below fills in; its diagonal (same trail) is closed.
class TrailsGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const TrailsGame({super.key, required this.problem});

  @override
  State<TrailsGame> createState() => _TrailsGameState();
}

class _TrailsGameState extends State<TrailsGame> {
  /// Trail picked for the way to the lake.
  int? _go;

  /// Trail picked for the way back (set while the walk animates).
  int? _back;

  /// Taps a trail number: first the way there, then a different way back.
  void onTapTrail(int i) {
    if (_back != null) return;
    if (_go == null) {
      setState(() => _go = i);
      return;
    }
    if (_go == i) {
      context.read<ProblemBloc>().add(const ProblemHintShown(
            'Abdulmalik boshqa so‘qmoq orqali qaytmoqchi! Boshqa so‘qmoqni tanla.',
          ));
      return;
    }
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 't$_go$i',
          label: '${_go! + 1}-so‘qmoqdan borib, ${i + 1}-so‘qmoqdan qaytish',
          emojis: const ['🚶'],
        )));
    setState(() => _back = i);
  }

  /// Walk finished — the map is ready for the next trip.
  void onWalkEnd() => setState(() {
        _go = null;
        _back = null;
      });

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, Set<String>>((b) => b.state.found.map((v) => v.key).toSet());
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHint(
          text: _go == null
              ? 'Abdulmalik qaysi so‘qmoqdan ko‘lga boradi? Raqamni bos'
              : _back == null
                  ? '${_go! + 1}-so‘qmoqdan boradi. Endi qaytish uchun boshqa so‘qmoqni bos'
                  : 'Abdulmalik yo‘lga chiqdi!',
          color: color,
        ),
        12.height,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: AspectRatio(
            aspectRatio: 2,
            child: LayoutBuilder(
              builder: (context, c) {
                final size = c.biggest;
                final disc = size.height * 0.15;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _MapPainter(go: _go, back: _back)),
                    ),
                    Positioned(
                      left: size.width * 0.01,
                      top: size.height * 0.28,
                      child: IgnorePointer(
                        child: Column(
                          children: [
                            Emoji('🏘️', size: size.height * 0.2),
                            Text('Qishloq', style: theme.display(size.height * 0.07)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.8,
                      right: 0,
                      top: size.height * 0.44,
                      child: IgnorePointer(
                        child: Text(
                          'Ko‘l',
                          textAlign: TextAlign.center,
                          style: theme.display(size.height * 0.08, color: theme.white),
                        ),
                      ),
                    ),
                    for (var i = 0; i < 3; i++)
                      Positioned(
                        left: _trailPoint(i, 0.5, size).dx - disc / 2,
                        top: _trailPoint(i, 0.5, size).dy - disc / 2,
                        width: disc,
                        height: disc,
                        child: GestureDetector(
                          onTap: () => onTapTrail(i),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutBack,
                              scale: _go == i || _back == i ? 1.2 : 1,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _go == i ? theme.green : (_back == i ? theme.secondary : theme.white),
                                  border: Border.all(color: theme.woodDark, width: 3),
                                  boxShadow: theme.lifted(theme.woodDark, depth: 0.3),
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: theme.display(disc * 0.5, color: _go == i || _back == i ? theme.white : theme.woodDark),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_back != null)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey('$_go$_back'),
                            tween: Tween(begin: 0, end: 2),
                            duration: const Duration(milliseconds: 2600),
                            onEnd: onWalkEnd,
                            builder: (context, t, _) {
                              final p = t <= 1 ? _trailPoint(_go!, t, size) : _trailPoint(_back!, 2 - t, size);
                              final s = size.height * 0.16;
                              return Stack(
                                children: [
                                  Positioned(left: p.dx - s / 2, top: p.dy - s * 0.9, child: Emoji('🚶', size: s)),
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Positioned(
                        left: _village.dx * size.width - size.height * 0.05,
                        top: _village.dy * size.height - size.height * 0.2,
                        child: IgnorePointer(child: Emoji('🧍', size: size.height * 0.14)),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        16.height,
        ShelfSection(
          title: 'Borish × qaytish jadvali',
          emoji: '📋',
          color: theme.violet,
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(78),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: 4.all,
                    child: Text('Borish ↓  Qaytish →', style: theme.body(12, color: theme.textMuted)),
                  ),
                  for (var b = 0; b < 3; b++)
                    Center(child: Text('${b + 1}', style: theme.display(22, color: theme.secondary))),
                ],
              ),
              for (var g = 0; g < 3; g++)
                TableRow(
                  children: [
                    Center(child: Text('${g + 1}', style: theme.display(22, color: theme.green))),
                    for (var b = 0; b < 3; b++)
                      Padding(
                        padding: 4.all,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: g == b
                                ? theme.line
                                : found.contains('t$g$b')
                                    ? (last == 't$g$b' ? theme.star.withValues(alpha: 0.45) : theme.white)
                                    : theme.surfaceSubtle,
                            borderRadius: 12.circular,
                            border: Border.all(
                              color: found.contains('t$g$b') ? color : theme.slotBorder,
                              width: found.contains('t$g$b') ? 3 : 2,
                            ),
                          ),
                          child: g == b
                              ? Icon(Icons.close_rounded, color: theme.textHint)
                              : found.contains('t$g$b')
                                  ? Text('${g + 1} → ${b + 1}', style: theme.display(18, color: color))
                                  : Icon(Icons.add_rounded, color: theme.slotBorder),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Meadow with the village, the lake and the three trails; the way there is
/// painted green, the way back orange.
class _MapPainter extends CustomPainter {
  /// Trail of the way there.
  final int? go;

  /// Trail of the way back.
  final int? back;

  _MapPainter({required this.go, required this.back});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.grass, theme.grassDark],
        ).createShader(rect),
    );
    // Lake.
    final lake = Rect.fromLTRB(w * 0.79, h * 0.24, w * 0.98, h * 0.76);
    canvas.drawOval(lake, Paint()..color = theme.blue.withValues(alpha: 0.75));
    canvas.drawOval(lake.deflate(10), Paint()..color = theme.cyan.withValues(alpha: 0.6));
    for (var i = 0; i < 3; i++) {
      final path = Path()
        ..moveTo(_village.dx * w, _village.dy * h)
        ..quadraticBezierTo(_controls[i].dx * w, _controls[i].dy * h, _lake.dx * w, _lake.dy * h);
      final highlight = i == go ? theme.green : (i == back ? theme.secondary : null);
      canvas.drawPath(
        path,
        Paint()
          ..color = highlight ?? theme.woodDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * (highlight == null ? 0.035 : 0.05)
          ..strokeCap = StrokeCap.round,
      );
      // Dashed centre line.
      final dash = Paint()
        ..color = theme.paper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (final m in path.computeMetrics()) {
        for (double d = 0; d < m.length; d += 16) {
          canvas.drawPath(m.extractPath(d, d + 8), dash);
        }
      }
    }
    canvas.drawCircle(Offset(_village.dx * w, _village.dy * h), 7, Paint()..color = theme.text);
    canvas.drawCircle(Offset(_lake.dx * w, _lake.dy * h), 7, Paint()..color = theme.text);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.go != go || old.back != back;
}
