import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/picnic_painters.dart';
import 'parts/pick_tile.dart';
import 'parts/table_slot.dart';

/// (name, carton colour, fruit colour, letter) of the three juices.
List<(String, Color, Color, String)> get _juices => [
      ('Olma', theme.greenObj, theme.red, 'O'),
      ('Shaftoli', theme.orange, theme.star, 'Sh'),
      ('Anor', theme.red, theme.pink, 'A'),
    ];

/// (emoji, name) of the four pastries.
const _pastries = [('🥯', 'Bulochka'), ('🥟', 'Somsa'), ('🥧', 'Pirog'), ('🍪', 'Pechenye')];

/// 4th grade problem 3 — school snack bar. Ruxsora picks one juice and one
/// pastry: the matching cell of the 3 × 4 table fills in. The table *is* the
/// solution — 3 rows × 4 columns.
class SnackBarGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const SnackBarGame({super.key, required this.problem});

  @override
  State<SnackBarGame> createState() => _SnackBarGameState();
}

class _SnackBarGameState extends State<SnackBarGame> {
  /// Picked juice index.
  int? _j;

  /// Picked pastry index.
  int? _p;

  /// Toggles a juice ([j]) or a pastry ([p]); a full pair becomes a variant.
  void _pick({int? j, int? p}) {
    setState(() {
      if (j != null) _j = _j == j ? null : j;
      if (p != null) _p = _p == p ? null : p;
    });
    if (_j == null || _p == null) return;
    final juice = _juices[_j!], pastry = _pastries[_p!];
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 's$_j$_p',
          label: '${juice.$1} sharbati + ${pastry.$2.toLowerCase()}',
          emojis: ['🧃', pastry.$1],
        )));
    setState(() {
      _j = null;
      _p = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final juices = _juices;
    final found = context.select<ProblemBloc, Set<String>>((b) => b.state.found.map((v) => v.key).toSet());
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    Widget juice(int i, double s) => CustomPaint(
          size: Size(s * 0.7, s),
          painter: JuicePainter(color: juices[i].$2, fruit: juices[i].$3, letter: juices[i].$4),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ShelfSection(
              title: 'Sharbatlar (3 ta)',
              emoji: '🧃',
              color: theme.greenObj,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < 3; i++)
                    PickTile(
                      picture: juice(i, 70),
                      label: juices[i].$1,
                      color: theme.greenObj,
                      selected: _j == i,
                      onTap: () => _pick(j: i),
                    ),
                ],
              ),
            ),
            ShelfSection(
              title: 'Shirinliklar (4 ta)',
              emoji: '🥐',
              color: color,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < 4; i++)
                    PickTile(
                      picture: Emoji(_pastries[i].$1, size: 50),
                      label: _pastries[i].$2,
                      color: color,
                      selected: _p == i,
                      onTap: () => _pick(p: i),
                    ),
                ],
              ),
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Nonushta to‘plamlari jadvali',
          emoji: '📋',
          color: theme.violet,
          child: LayoutBuilder(
            builder: (context, c) {
              final cell = ((c.maxWidth - 40) / 5).clamp(62.0, 140.0);
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
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: cell, child: const Center(child: Emoji('🍽️', size: 30))),
                        for (var p = 0; p < 4; p++)
                          Padding(
                            padding: 4.all,
                            child: header(
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Emoji(_pastries[p].$1, size: 26),
                                  Text(_pastries[p].$2, style: theme.body(12), maxLines: 1),
                                ],
                              ),
                              _p == p,
                            ),
                          ),
                      ],
                    ),
                    for (var j = 0; j < 3; j++)
                      Row(
                        children: [
                          header(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [juice(j, 34), 4.width, Text(juices[j].$1, style: theme.body(12), maxLines: 1)],
                            ),
                            _j == j,
                          ),
                          for (var p = 0; p < 4; p++)
                            Padding(
                              padding: 4.all,
                              child: TableSlot(
                                size: cell,
                                filled: found.contains('s$j$p'),
                                flash: last == 's$j$p',
                                color: color,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [juice(j, cell * 0.36), Emoji(_pastries[p].$1, size: cell * 0.26)],
                                ),
                              ),
                            ),
                        ],
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
}
