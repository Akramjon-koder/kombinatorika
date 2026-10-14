import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

/// (name, avatar) of the five club members.
const _players = [('Ali', '🧒🏻'), ('Vali', '👦🏽'), ('Sardor', '🧑🏻'), ('Madina', '👧🏻'), ('Nilufar', '👧🏽')];

/// Seat of player [i] around the round table (fractions; a regular pentagon).
Offset _seat(int i) {
  final a = -pi / 2 + i * 2 * pi / 5;
  return Offset(0.5 + cos(a) * 0.38, 0.5 + sin(a) * 0.38);
}

/// 4th grade problem 7 — chess club. Tap two players: a chess game line joins
/// them and both cells of the round-robin table get a pawn — "Ali — Vali" and
/// "Vali — Ali" is one and the same game.
class ChessGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const ChessGame({super.key, required this.problem});

  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  /// First player of the game being set up.
  int? _first;

  /// Picks the first player, or starts a game with the second one.
  void onTapPlayer(int i) {
    if (_first == null || _first == i) {
      setState(() => _first = _first == i ? null : i);
      return;
    }
    final a = min(_first!, i), b = max(_first!, i);
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'c$a$b',
          label: '${_players[a].$1} — ${_players[b].$1}',
          emojis: const ['♟️'],
        )));
    setState(() => _first = null);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, Set<String>>((b) => b.state.found.map((v) => v.key).toSet());
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    final games = [for (final k in found) (int.parse(k[1]), int.parse(k[2]))];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHint(
          text: _first == null
              ? 'Kim kim bilan o‘ynaydi? Birinchi o‘quvchini bos'
              : '${_players[_first!].$1} tanlandi — endi raqibini bos',
          color: color,
        ),
        12.height,
        Wrap(
          spacing: 20,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final seat = w * 0.22;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _ClubPainter(games: games, color: color)),
                      ),
                      const Center(child: IgnorePointer(child: Emoji('🏆', size: 40))),
                      for (var i = 0; i < 5; i++)
                        Positioned(
                          left: _seat(i).dx * w - seat / 2,
                          top: _seat(i).dy * w - seat / 2,
                          width: seat,
                          height: seat,
                          child: GestureDetector(
                            onTap: () => onTapPlayer(i),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutBack,
                                scale: _first == i ? 1.18 : 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _first == i ? color : theme.line, width: 4),
                                    boxShadow: theme.lifted(color, depth: 0.3),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Emoji(_players[i].$2, size: seat * 0.4),
                                      Text(_players[i].$1, style: theme.body(seat * 0.15)),
                                    ],
                                  ),
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
            ShelfSection(
              title: 'O‘yinlar jadvali',
              emoji: '📋',
              color: theme.violet,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(54),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      const SizedBox.shrink(),
                      for (final p in _players) Center(child: Emoji(p.$2, size: 26)),
                    ],
                  ),
                  for (var r = 0; r < 5; r++)
                    TableRow(
                      children: [
                        Padding(
                          padding: 2.all,
                          child: Text(_players[r].$1, style: theme.body(12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        for (var c = 0; c < 5; c++)
                          Builder(
                            builder: (context) {
                              final key = 'c${min(r, c)}${max(r, c)}';
                              final played = r != c && found.contains(key);
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                margin: 3.all,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: r == c
                                      ? theme.line
                                      : played
                                          ? (last == key ? theme.star.withValues(alpha: 0.5) : theme.white)
                                          : theme.surfaceSubtle,
                                  borderRadius: 10.circular,
                                  border: Border.all(color: played ? color : theme.slotBorder, width: played ? 2.5 : 1.5),
                                ),
                                child: r == c
                                    ? Icon(Icons.close_rounded, color: theme.textHint, size: 20)
                                    : played
                                        ? const Emoji('♟️', size: 22)
                                        : null,
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Round club table and a line for every game played.
class _ClubPainter extends CustomPainter {
  /// Played games as (player, player) pairs.
  final List<(int, int)> games;

  /// Line colour.
  final Color color;

  _ClubPainter({required this.games, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final center = Offset(w / 2, size.height / 2);
    canvas.drawCircle(center, w * 0.4, Paint()..color = theme.woodLight.withValues(alpha: 0.35));
    canvas.drawCircle(
      center,
      w * 0.4,
      Paint()
        ..color = theme.woodDark.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    for (final (a, b) in games) {
      canvas.drawLine(
        _seat(a) * w,
        _seat(b) * w,
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClubPainter old) => old.games.length != games.length;
}
