import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/bowl_painter.dart';
import 'parts/pick_tile.dart';

/// (name, porridge colour, berries) of the three porridges.
List<(String, Color, bool)> get _porridges => [
      ('Qora bug‘doy', theme.hair, false),
      ('Manniy', theme.paper, false),
      ('Suli', theme.woodLight, true),
    ];

const _drinks = [('🍵', 'Choy'), ('🥛', 'Qatiq'), ('🧃', 'Sharbat')];

/// Problem 4 — breakfast table. Pick a porridge and a drink: the matching cell
/// of the 3 × 3 breakfast table fills in. The table *is* the solution.
class BreakfastGame extends StatefulWidget {
  final Problem problem;

  const BreakfastGame({super.key, required this.problem});

  @override
  State<BreakfastGame> createState() => _BreakfastGameState();
}

class _BreakfastGameState extends State<BreakfastGame> {
  int? _p;
  int? _d;

  void _pick({int? p, int? d}) {
    setState(() {
      if (p != null) _p = _p == p ? null : p;
      if (d != null) _d = _d == d ? null : d;
    });
    if (_p != null && _d != null) {
      final porridge = _porridges[_p!], drink = _drinks[_d!];
      context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
            key: 'b$_p$_d',
            label: '${porridge.$1} + ${drink.$2.toLowerCase()}',
            emojis: ['🥣', drink.$1],
          )));
      setState(() {
        _p = null;
        _d = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final porridges = _porridges;
    final found = context.select<ProblemBloc, Set<String>>(
      (b) => b.state.found.map((v) => v.key).toSet(),
    );
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    Widget bowl(int i, double s) => CustomPaint(
          size: Size(s, s * 0.8),
          painter: BowlPainter(porridge: porridges[i].$2, bowl: theme.cyan, berries: porridges[i].$3),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ShelfSection(
              title: 'Bo‘tqalar',
              emoji: '🥣',
              color: color,
              child: Wrap(
                spacing: 10,
                children: [
                  for (var i = 0; i < 3; i++)
                    PickTile(
                      picture: bowl(i, 70),
                      label: porridges[i].$1,
                      color: color,
                      selected: _p == i,
                      onTap: () => _pick(p: i),
                    ),
                ],
              ),
            ),
            ShelfSection(
              title: 'Ichimliklar',
              emoji: '🥤',
              color: theme.cyan,
              child: Wrap(
                spacing: 10,
                children: [
                  for (var i = 0; i < 3; i++)
                    PickTile(
                      picture: Emoji(_drinks[i].$1, size: 50),
                      label: _drinks[i].$2,
                      color: theme.cyan,
                      selected: _d == i,
                      onTap: () => _pick(d: i),
                    ),
                ],
              ),
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Nonushta jadvali',
          emoji: '📋',
          color: theme.violet,
          child: LayoutBuilder(
            builder: (context, c) {
              final cell = ((c.maxWidth - 30) / 4).clamp(70.0, 150.0);
              Widget header(Widget child, bool on) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: cell,
                    height: cell * 0.7,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? theme.star.withValues(alpha: 0.4) : theme.white,
                      borderRadius: 14.circular,
                    ),
                    child: child,
                  );
              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: cell, child: const Center(child: Emoji('🍽️', size: 30))),
                      for (var d = 0; d < 3; d++)
                        Padding(
                          padding: 4.all,
                          child: header(
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [Emoji(_drinks[d].$1, size: 28), Text(_drinks[d].$2, style: theme.body(13))],
                            ),
                            _d == d,
                          ),
                        ),
                    ],
                  ),
                  for (var p = 0; p < 3; p++)
                    Row(
                      children: [
                        header(
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [bowl(p, 36), Text(porridges[p].$1, style: theme.body(12), maxLines: 1)],
                          ),
                          _p == p,
                        ),
                        for (var d = 0; d < 3; d++)
                          Padding(
                            padding: 4.all,
                            child: _Cell(
                              size: cell,
                              filled: found.contains('b$p$d'),
                              flash: last == 'b$p$d',
                              color: color,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [bowl(p, cell * 0.36), Emoji(_drinks[d].$1, size: cell * 0.24)],
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final double size;
  final bool filled;
  final bool flash;
  final Color color;
  final Widget child;

  const _Cell({required this.size, required this.filled, required this.flash, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: size,
      height: size * 0.7,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? (flash ? theme.star.withValues(alpha: 0.45) : theme.white) : theme.surfaceSubtle,
        borderRadius: 14.circular,
        border: Border.all(color: filled ? color : theme.slotBorder, width: filled ? 3 : 2),
        boxShadow: filled ? theme.lifted(color, depth: 0.3) : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
        child: filled ? child : Icon(Icons.add_rounded, color: theme.slotBorder, size: 28),
      ),
    );
  }
}
