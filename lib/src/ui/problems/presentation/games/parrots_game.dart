import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/parrot_painter.dart';
import 'parts/pick_tile.dart';

/// (name, accent colour, look) of the four parrots from the worksheet picture.
List<(String, Color, ParrotLook)> get _parrots => [
      (
        'Oq kakadu',
        theme.grey,
        ParrotLook(
          head: theme.white,
          body: theme.surfaceSubtle,
          chest: theme.white,
          wing: theme.line,
          tail: theme.line,
          beak: theme.text,
          crest: theme.yellow,
        ),
      ),
      (
        'Qizil ara',
        theme.red,
        ParrotLook(head: theme.red, body: theme.red, chest: theme.red, wing: theme.yellow, tail: theme.blue, beak: theme.paper),
      ),
      (
        'Yashil kvezal',
        theme.greenObj,
        ParrotLook(
          head: theme.greenObj,
          body: theme.greenObj,
          chest: theme.red,
          wing: theme.grassDark,
          tail: theme.grassDark,
          beak: theme.yellow,
          longTail: true,
        ),
      ),
      (
        'Ko‘k lori',
        theme.blue,
        ParrotLook(head: theme.blue, body: theme.greenObj, chest: theme.orange, wing: theme.grassDark, tail: theme.blue, beak: theme.orange),
      ),
    ];

/// Colour dots of the parrots for the side-panel list.
const _dots = ['⚪', '🔴', '🟢', '🔵'];

/// 4th grade problem 8 — parrots. Pick two parrots and put them into the cage;
/// every cage pair is kept on the shelf. The same two parrots picked in the
/// other order are the same choice.
class ParrotsGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const ParrotsGame({super.key, required this.problem});

  @override
  State<ParrotsGame> createState() => _ParrotsGameState();
}

class _ParrotsGameState extends State<ParrotsGame> {
  /// Picked parrots (at most two).
  final List<int> _picked = [];

  /// Pair that sits in the big cage right now.
  List<int> _cage = const [];

  /// Toggles parrot [i]; a third pick is refused.
  void onTapParrot(int i) {
    if (_picked.contains(i)) {
      setState(() => _picked.remove(i));
    } else if (_picked.length < 2) {
      setState(() => _picked.add(i));
    } else {
      context.read<ProblemBloc>().add(const ProblemHintShown('Katakka faqat 2 ta to‘tiqush sig‘adi!'));
    }
  }

  /// Puts the two picked parrots into the cage and records the pair.
  void onTapCage() {
    final s = [..._picked]..sort();
    final parrots = _parrots;
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'p${s[0]}${s[1]}',
          label: '${parrots[s[0]].$1} + ${parrots[s[1]].$1.toLowerCase()}',
          emojis: [_dots[s[0]], _dots[s[1]]],
        )));
    setState(() {
      _cage = s;
      _picked.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final parrots = _parrots;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    Widget parrot(int i, double s) => CustomPaint(size: Size(s * 0.8, s), painter: ParrotPainter(parrots[i].$3));
    Widget cage(List<int> pair, double w) => SizedBox(
          width: w,
          height: w * 1.1,
          child: CustomPaint(
            foregroundPainter: _CagePainter(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(w * 0.08, w * 0.3, w * 0.08, w * 0.12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [for (final i in pair) parrot(i, w * 0.5)],
              ),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            ShelfSection(
              title: 'To‘tiqushlar (4 ta)',
              emoji: '🦜',
              color: color,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < 4; i++)
                    PickTile(
                      picture: parrot(i, 66),
                      label: parrots[i].$1,
                      color: parrots[i].$2,
                      selected: _picked.contains(i),
                      onTap: () => onTapParrot(i),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: KeyedSubtree(key: ValueKey(_cage.join()), child: cage(_cage, 150)),
                ),
                8.height,
                ClayButton(
                  color: theme.green,
                  onTap: _picked.length == 2 ? onTapCage : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.door_sliding_rounded),
                      8.width,
                      Text('Katakka solish (${_picked.length}/2)'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Tanlangan juftliklar',
          emoji: '🪺',
          color: theme.violet,
          child: found.isEmpty
              ? Text('Hali katak bo‘sh', style: theme.body(15, color: theme.textHint))
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final v in found)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: 6.all,
                        decoration: BoxDecoration(
                          color: last == v.key ? theme.star.withValues(alpha: 0.45) : theme.white,
                          borderRadius: 16.circular,
                        ),
                        child: cage([int.parse(v.key[1]), int.parse(v.key[2])], 96),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Bird cage drawn over its content: dome, bars, base and a hook.
class _CagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bar = Paint()
      ..color = theme.woodDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    final top = h * 0.3;
    final dome = Rect.fromLTRB(w * 0.06, h * 0.08, w * 0.94, top * 2 - h * 0.08);
    canvas.drawArc(dome, pi, pi, false, bar);
    // Every bar rises straight, then bends along the dome into the top ring.
    final apex = Offset(w / 2, h * 0.08);
    for (var i = 0; i <= 6; i++) {
      final x = w * 0.06 + (w * 0.88) * i / 6;
      canvas.drawPath(
        Path()
          ..moveTo(x, h * 0.9)
          ..lineTo(x, top)
          ..quadraticBezierTo(x, apex.dy, apex.dx, apex.dy),
        bar,
      );
    }
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.02, h * 0.88, w * 0.98, h * 0.98, Radius.circular(w * 0.04)),
      Paint()..color = theme.wood,
    );
    canvas.drawCircle(Offset(w / 2, h * 0.04), w * 0.04, bar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
