import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/ice_cream_painter.dart';
import 'parts/pick_tile.dart';

/// Names of the two containers (index 0 is the cone).
const _containers = ['Konus', 'Stakan'];

/// (name, scoop colour) of the three flavours.
List<(String, Color)> get _flavors => [
      ('Vanil', theme.yellow),
      ('Shokolad', theme.hair),
      ('Qulupnay', theme.pink),
    ];

/// Names of the two toppings (index 0 is nuts).
const _toppings = ['Yong‘oq', 'Rangli sepma'];

/// 4th grade problem 9 — ice-cream shop. Choose a container, a flavour and a
/// topping: the ice cream is built live, "Buyurtma" puts it on the counter.
/// Orders are grouped by container so the 2 × 3 × 2 tree is visible.
class IceCreamGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const IceCreamGame({super.key, required this.problem});

  @override
  State<IceCreamGame> createState() => _IceCreamGameState();
}

class _IceCreamGameState extends State<IceCreamGame> {
  /// Chosen container index.
  int? _c;

  /// Chosen flavour index.
  int? _f;

  /// Chosen topping index.
  int? _t;

  /// Records the finished ice cream and clears the choice.
  void onTapOrder() {
    final flavors = _flavors;
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'i$_c$_f$_t',
          label: '${_containers[_c!]} · ${flavors[_f!].$1.toLowerCase()} · ${_toppings[_t!].toLowerCase()}',
          emojis: [_c == 0 ? '🍦' : '🍨'],
        )));
    setState(() {
      _c = null;
      _f = null;
      _t = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final flavors = _flavors;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    Widget ice({int? c, int? f, int? t, required double s}) => CustomPaint(
          size: Size(s * 0.8, s),
          painter: IceCreamPainter(
            cone: c == null ? null : c == 0,
            flavor: f == null ? null : flavors[f].$2,
            nuts: t == null ? null : t == 0,
          ),
        );
    final ready = _c != null && _f != null && _t != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            ShelfSection(
              title: '1. Idish',
              emoji: '🍦',
              color: theme.woodDark,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 2; i++) ...[
                    PickTile(
                      picture: ice(c: i, s: 70),
                      label: _containers[i],
                      color: theme.woodDark,
                      width: 120,
                      selected: _c == i,
                      onTap: () => setState(() => _c = _c == i ? null : i),
                    ),
                    8.width,
                  ],
                ],
              ),
            ),
            ShelfSection(
              title: '2. Ta’m',
              emoji: '🍨',
              color: theme.pink,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    PickTile(
                      picture: ice(f: i, s: 70),
                      label: flavors[i].$1,
                      color: theme.pink,
                      width: 120,
                      selected: _f == i,
                      onTap: () => setState(() => _f = _f == i ? null : i),
                    ),
                    8.width,
                  ],
                ],
              ),
            ),
            ShelfSection(
              title: '3. Sepma',
              emoji: '✨',
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 2; i++) ...[
                    PickTile(
                      picture: ice(f: 0, t: i, s: 70),
                      label: _toppings[i],
                      color: color,
                      width: 120,
                      selected: _t == i,
                      onTap: () => setState(() => _t = _t == i ? null : i),
                    ),
                    8.width,
                  ],
                ],
              ),
            ),
          ],
        ),
        16.height,
        Wrap(
          spacing: 20,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 150,
              height: 170,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.white,
                borderRadius: 22.circular,
                border: Border.all(color: ready ? theme.green : theme.slotBorder, width: 3),
              ),
              child: _c == null && _f == null
                  ? Padding(
                      padding: 10.all,
                      child: Text(
                        'Idish, ta’m va sepmani tanla',
                        textAlign: TextAlign.center,
                        style: theme.body(14, color: theme.textHint),
                      ),
                    )
                  : ice(c: _c, f: _f, t: _t, s: 140),
            ),
            ClayButton(
              color: theme.green,
              onTap: ready ? onTapOrder : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.room_service_rounded),
                  8.width,
                  const Text('Buyurtma berish'),
                ],
              ),
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Sardorning buyurtmalari',
          emoji: '🧾',
          color: theme.violet,
          child: found.isEmpty
              ? Text('Hali buyurtma yo‘q', style: theme.body(15, color: theme.textHint))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var c = 0; c < 2; c++)
                      if (found.any((v) => v.key[1] == '$c'))
                        Padding(
                          padding: 8.bottom,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(width: 70, child: Text(_containers[c], style: theme.display(17))),
                              for (final v in found.where((v) => v.key[1] == '$c').toList()..sort((a, b) => a.key.compareTo(b.key)))
                                Tooltip(
                                  message: v.label,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    padding: 4.all,
                                    decoration: BoxDecoration(
                                      color: last == v.key ? theme.star.withValues(alpha: 0.45) : theme.white,
                                      borderRadius: 12.circular,
                                    ),
                                    child: ice(
                                      c: int.parse(v.key[1]),
                                      f: int.parse(v.key[2]),
                                      t: int.parse(v.key[3]),
                                      s: 52,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                  ],
                ),
        ),
      ],
    );
  }
}
