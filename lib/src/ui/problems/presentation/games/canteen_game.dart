import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

const _mains = [('🍖', 'Kotlet'), ('🌭', 'Sosiska'), ('🍳', 'Qovurilgan tuxum')];
const _sides = [('🥗', 'Sabzavot'), ('🍝', 'Makaron'), ('🥔', 'Kartoshka pyuresi')];

String _key(int m, int s) => 'm$m-s$s';

/// Problem 1 — school canteen. Put a main dish and a side dish on the plate;
/// every served dish lights up a leaf of the "dish tree" (3 branches × 3).
class CanteenGame extends StatefulWidget {
  final Problem problem;

  const CanteenGame({super.key, required this.problem});

  @override
  State<CanteenGame> createState() => _CanteenGameState();
}

class _CanteenGameState extends State<CanteenGame> {
  int? _main;
  int? _side;
  bool _serving = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pick({int? main, int? side}) {
    if (_serving) return;
    setState(() {
      if (main != null) _main = _main == main ? null : main;
      if (side != null) _side = _side == side ? null : side;
    });
    if (_main != null && _side != null) {
      setState(() => _serving = true);
      _timer = Timer(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        final m = _mains[_main!], s = _sides[_side!];
        context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
              key: _key(_main!, _side!),
              label: '${m.$2} + ${s.$2.toLowerCase()}',
              emojis: [m.$1, s.$1],
            )));
        setState(() {
          _main = null;
          _side = null;
          _serving = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, Set<String>>(
      (b) => b.state.found.map((v) => v.key).toSet(),
    );
    final step = _main == null
        ? 'Asosiy taomni tanla'
        : _side == null
            ? 'Endi garnirni tanla'
            : 'Taom tayyorlanmoqda…';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ShelfSection(
              title: 'Asosiy taomlar (3 ta)',
              emoji: '🍖',
              color: color,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < 3; i++)
                    PickTile(
                      picture: Emoji(_mains[i].$1, size: 48),
                      label: _mains[i].$2,
                      color: color,
                      badge: '${i + 1}',
                      selected: _main == i,
                      onTap: () => _pick(main: i),
                    ),
                ],
              ),
            ),
            _Plate(main: _main, side: _side, serving: _serving),
            ShelfSection(
              title: 'Garnirlar (3 ta)',
              emoji: '🥗',
              color: theme.greenObj,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < 3; i++)
                    PickTile(
                      picture: Emoji(_sides[i].$1, size: 48),
                      label: _sides[i].$2,
                      color: theme.greenObj,
                      badge: String.fromCharCode(65 + i),
                      selected: _side == i,
                      onTap: () => _pick(side: i),
                    ),
                ],
              ),
            ),
          ],
        ),
        12.height,
        StepHint(text: step, color: color),
        16.height,
        ShelfSection(
          title: 'Taomlar daraxti',
          emoji: '🌳',
          color: theme.grassDark,
          child: SizedBox(height: 230, child: _DishTree(found: found, color: color)),
        ),
      ],
    );
  }
}

/// Big plate (top view) showing what is being composed.
class _Plate extends StatelessWidget {
  final int? main;
  final int? side;
  final bool serving;

  const _Plate({required this.main, required this.side, required this.serving});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      scale: serving ? 1.12 : 1,
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.white,
          border: Border.all(color: theme.line, width: 10),
          boxShadow: [
            BoxShadow(color: theme.black.withValues(alpha: 0.15), offset: const Offset(0, 10), blurRadius: 18),
            if (serving) BoxShadow(color: theme.star.withValues(alpha: 0.7), blurRadius: 30, spreadRadius: 4),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (main == null && side == null)
              Text('Likopcha', style: theme.body(15, color: theme.textHint)),
            if (main != null)
              Align(alignment: const Alignment(-0.35, -0.1), child: Emoji(_mains[main!].$1, size: 56)),
            if (side != null)
              Align(alignment: const Alignment(0.4, 0.2), child: Emoji(_sides[side!].$1, size: 50)),
            if (serving) const Align(alignment: Alignment(0.7, -0.75), child: Emoji('✨', size: 30)),
          ],
        ),
      ),
    );
  }
}

/// Root → 3 main dishes → 3 sides each. Found leaves glow.
class _DishTree extends StatelessWidget {
  final Set<String> found;
  final Color color;

  const _DishTree({required this.found, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final root = Offset(w / 2, 26);
        final mains = [for (var i = 0; i < 3; i++) Offset(w * (2 * i + 1) / 6, 105)];
        final leaves = [
          for (var i = 0; i < 3; i++)
            for (var j = 0; j < 3; j++) Offset(w * (i * 3 + j + 0.5) / 9, 195),
        ];
        final lit = [
          for (var i = 0; i < 3; i++)
            for (var j = 0; j < 3; j++) found.contains(_key(i, j)),
        ];
        Widget node(Offset o, String emoji, {required bool on, double r = 24}) => Positioned(
              left: o.dx - r,
              top: o.dy - r,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: r * 2,
                height: r * 2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? theme.white : theme.surfaceSubtle,
                  border: Border.all(color: on ? color : theme.slotBorder, width: 3),
                  boxShadow: on ? theme.lifted(color, depth: 0.4) : null,
                ),
                child: Opacity(opacity: on ? 1 : 0.25, child: Emoji(emoji, size: r)),
              ),
            );
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _TreeLines(root: root, mains: mains, leaves: leaves, lit: lit, color: color),
              ),
            ),
            node(root, '🍽️', on: true),
            for (var i = 0; i < 3; i++)
              node(mains[i], _mains[i].$1, on: lit.sublist(i * 3, i * 3 + 3).any((e) => e)),
            for (var k = 0; k < 9; k++) node(leaves[k], _sides[k % 3].$1, on: lit[k], r: 21),
          ],
        );
      },
    );
  }
}

class _TreeLines extends CustomPainter {
  final Offset root;
  final List<Offset> mains;
  final List<Offset> leaves;
  final List<bool> lit;
  final Color color;

  _TreeLines({required this.root, required this.mains, required this.leaves, required this.lit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p(bool on) => Paint()
      ..color = on ? color : theme.slotBorder
      ..strokeWidth = on ? 4 : 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      final anyOn = lit.sublist(i * 3, i * 3 + 3).any((e) => e);
      canvas.drawLine(root, mains[i], p(anyOn));
      for (var j = 0; j < 3; j++) {
        canvas.drawLine(mains[i], leaves[i * 3 + j], p(lit[i * 3 + j]));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeLines old) => true;
}
