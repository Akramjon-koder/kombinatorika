import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/kid_painter.dart';
import 'parts/pick_tile.dart';

/// One child of the dance group.
class _Kid {
  final String name;
  final bool girl;
  final Color costume;
  final Color accent;

  const _Kid(this.name, this.girl, this.costume, this.accent);
}

/// The eight children of the worksheet picture.
List<_Kid> get _kids => [
      _Kid('Aziz', false, theme.greenObj, theme.white),
      _Kid('Malika', true, theme.yellow, theme.red),
      _Kid('Bobur', false, theme.hair, theme.star),
      _Kid('Dilnoza', true, theme.text, theme.star),
      _Kid('Sardor', false, theme.woodDark, theme.red),
      _Kid('Gulnora', true, theme.orange, theme.violet),
      _Kid('Jasur', false, theme.cyan, theme.white),
      _Kid('Nilufar', true, theme.pink, theme.cyan),
    ];

/// Problem 6 — dance floor. Tap a child, then another: they hold hands and
/// step onto the stage as a dancing pair. Tap a pair to send it back.
class DancersGame extends StatefulWidget {
  final Problem problem;

  const DancersGame({super.key, required this.problem});

  @override
  State<DancersGame> createState() => _DancersGameState();
}

class _DancersGameState extends State<DancersGame> with SingleTickerProviderStateMixin {
  late final AnimationController _dance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  final List<(int, int)> _pairs = [];
  int? _first;

  @override
  void dispose() {
    _dance.dispose();
    super.dispose();
  }

  bool _paired(int i) => _pairs.any((p) => p.$1 == i || p.$2 == i);

  void onTapKid(int i) {
    if (_first == null) {
      setState(() => _first = i);
      return;
    }
    if (_first == i) {
      setState(() => _first = null);
      return;
    }
    final a = min(_first!, i), b = max(_first!, i);
    final kids = _kids;
    setState(() {
      _pairs.add((a, b));
      _first = null;
    });
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'p$a-$b',
          label: '${kids[a].name} va ${kids[b].name}',
          emojis: [kids[a].girl ? '👧' : '👦', kids[b].girl ? '👧' : '👦'],
        )));
  }

  void onTapPair((int, int) pair) {
    setState(() => _pairs.remove(pair));
    context.read<ProblemBloc>().add(ProblemVariantRemoved('p${pair.$1}-${pair.$2}'));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final kids = _kids;
    final waiting = [for (var i = 0; i < kids.length; i++) if (!_paired(i)) i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfSection(
          title: 'Raqs sahnasi — juftliklar: ${_pairs.length}',
          emoji: '🪩',
          color: color,
          child: Container(
            constraints: const BoxConstraints(minHeight: 170),
            width: double.infinity,
            padding: 12.all,
            decoration: BoxDecoration(
              borderRadius: 18.circular,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.violet.withValues(alpha: 0.18), theme.woodLight.withValues(alpha: 0.5)],
              ),
            ),
            child: _pairs.isEmpty
                ? SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Juftliklar shu sahnada raqs tushadi 💃🕺',
                        style: theme.body(16, color: theme.textMuted),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (var k = 0; k < _pairs.length; k++)
                        _PairCard(
                          number: k + 1,
                          a: kids[_pairs[k].$1],
                          b: kids[_pairs[k].$2],
                          dance: _dance,
                          color: color,
                          onTap: () => onTapPair(_pairs[k]),
                        ),
                    ],
                  ),
          ),
        ),
        14.height,
        StepHint(
          text: _first == null
              ? 'Bolani bos — keyin uning juftini tanla'
              : '${kids[_first!].name} kim bilan raqs tushadi?',
          color: color,
        ),
        14.height,
        ShelfSection(
          title: 'Bolalar (${waiting.length} ta kutmoqda)',
          emoji: '🧒',
          color: theme.cyan,
          child: waiting.isEmpty
              ? Padding(
                  padding: 12.all,
                  child: Text('Hamma bolalar juft bo‘ldi! 🎉', style: theme.display(20, color: theme.green)),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final i in waiting)
                      PickTile(
                        picture: CustomPaint(
                          size: const Size(58, 78),
                          painter: KidPainter(girl: kids[i].girl, costume: kids[i].costume, accent: kids[i].accent),
                        ),
                        label: kids[i].name,
                        color: theme.cyan,
                        width: 100,
                        selected: _first == i,
                        onTap: () => onTapKid(i),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Two kids holding hands and swaying, with a number badge.
class _PairCard extends StatelessWidget {
  final int number;
  final _Kid a;
  final _Kid b;
  final Animation<double> dance;
  final Color color;
  final VoidCallback onTap;

  const _PairCard({
    required this.number,
    required this.a,
    required this.b,
    required this.dance,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Juftlikni ajratish',
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              decoration: BoxDecoration(
                color: theme.white,
                borderRadius: 20.circular,
                border: Border.all(color: color, width: 3),
                boxShadow: theme.lifted(color, depth: 0.4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(color: color, borderRadius: 10.circular),
                        child: Text('$number', style: theme.display(15, color: theme.white)),
                      ),
                      6.width,
                      const Emoji('🎶', size: 16),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: dance,
                    builder: (context, _) {
                      final s = dance.value * 2 - 1;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: s * 0.12,
                            child: CustomPaint(
                              size: const Size(54, 74),
                              painter: KidPainter(girl: a.girl, costume: a.costume, accent: a.accent, swing: s),
                            ),
                          ),
                          Transform.rotate(
                            angle: -s * 0.12,
                            child: CustomPaint(
                              size: const Size(54, 74),
                              painter: KidPainter(girl: b.girl, costume: b.costume, accent: b.accent, swing: -s),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Text('${a.name} + ${b.name}', style: theme.body(13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
