import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/balloon_painter.dart';
import 'parts/pick_tile.dart';

/// (name, colour, colour emoji) of the five balloons.
List<(String, Color, String)> get _balloons => [
      ('Qizil', theme.red, '🔴'),
      ('Ko‘k', theme.blue, '🔵'),
      ('Sariq', theme.yellow, '🟡'),
      ('Yashil', theme.greenObj, '🟢'),
      ('Oq', theme.surfaceSubtle, '⚪'),
    ];

/// 4th grade problem 4 — party balloons. Tap two balloons of different
/// colours: they fly into a gift pack. A pack with the same two colours in
/// the other order is the same pack (the bloc flags it as a duplicate).
class BalloonsGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const BalloonsGame({super.key, required this.problem});

  @override
  State<BalloonsGame> createState() => _BalloonsGameState();
}

class _BalloonsGameState extends State<BalloonsGame> {
  /// First balloon of the pack being tied.
  int? _first;

  /// Picks the first balloon, or ties the pack with the second one.
  void onTapBalloon(int i) {
    if (_first == null || _first == i) {
      setState(() => _first = _first == i ? null : i);
      return;
    }
    final a = _first! < i ? _first! : i, b = _first! < i ? i : _first!;
    final balloons = _balloons;
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'bl$a$b',
          label: '${balloons[a].$1} + ${balloons[b].$1.toLowerCase()} shar',
          emojis: [balloons[a].$3, balloons[b].$3],
        )));
    setState(() => _first = null);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final balloons = _balloons;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHint(
          text: _first == null
              ? 'Paketga qaysi 2 ta shar solinadi? Birinchi sharni bos'
              : '${balloons[_first!].$1} shar tanlandi — endi boshqa rangli sharni bos',
          color: color,
        ),
        12.height,
        ShelfSection(
          title: 'Bayram sharlari (5 ta)',
          emoji: '🎈',
          color: color,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < 5; i++)
                AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  offset: Offset(0, _first == i ? -0.08 : 0),
                  child: PickTile(
                    picture: CustomPaint(size: const Size(52, 74), painter: BalloonPainter(balloons[i].$2)),
                    label: balloons[i].$1,
                    color: i == 4 ? theme.grey : balloons[i].$2,
                    selected: _first == i,
                    width: 100,
                    onTap: () => onTapBalloon(i),
                  ),
                ),
            ],
          ),
        ),
        16.height,
        ShelfSection(
          title: 'Sovg‘a paketlari',
          emoji: '🎁',
          color: theme.violet,
          child: found.isEmpty
              ? Text('Hali paket yo‘q', style: theme.body(15, color: theme.textHint))
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final v in found)
                      TweenAnimationBuilder<double>(
                        key: ValueKey(v.key),
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        builder: (context, t, child) => Transform.scale(scale: t, child: child),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 96,
                          padding: 8.all,
                          decoration: BoxDecoration(
                            color: last == v.key ? theme.star.withValues(alpha: 0.4) : theme.white,
                            borderRadius: 16.circular,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (final k in [v.key[2], v.key[3]])
                                    CustomPaint(
                                      size: const Size(30, 44),
                                      painter: BalloonPainter(balloons[int.parse(k)].$2),
                                    ),
                                ],
                              ),
                              const Emoji('🎁', size: 30),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
