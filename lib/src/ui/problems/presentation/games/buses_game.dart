import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/bus_painter.dart';
import 'parts/pick_tile.dart';

/// (name, colour) of the six buses in the worksheet.
List<(String, Color)> get _buses => [
      ('qizil', theme.red),
      ('sariq', theme.yellow),
      ('yashil', theme.greenObj),
      ('ko‘k', theme.blue),
      ('to‘q sariq', theme.orange),
      ('zangori', theme.mint),
    ];

/// Problem 7 — bus station. Drag the trip leader onto a bus (or tap the bus):
/// the leader gets in, the bus honks and drives a little, then comes back.
/// Each bus is one possibility.
class BusesGame extends StatefulWidget {
  final Problem problem;

  const BusesGame({super.key, required this.problem});

  @override
  State<BusesGame> createState() => _BusesGameState();
}

class _BusesGameState extends State<BusesGame> {
  int? _riding;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void board(int i) {
    if (_riding != null) return;
    final buses = _buses;
    setState(() => _riding = i);
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'bus$i',
          label: '${i + 1}-avtobus (${buses[i].$1})',
          emojis: const ['🧑‍🏫', '🚌'],
        )));
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _riding = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final buses = _buses;
    final found = context.select<ProblemBloc, Set<String>>(
      (b) => b.state.found.map((v) => v.key).toSet(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Draggable<int>(
              data: 0,
              feedback: Material(color: theme.transparent, child: const Emoji('🧑‍🏫', size: 70)),
              childWhenDragging: Opacity(opacity: 0.3, child: _Leader(color: color)),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _riding == null ? 1 : 0.25,
                child: _Leader(color: color),
              ),
            ),
            16.width,
            Expanded(
              child: StepHint(
                text: 'Sayr rahbarini avtobusga olib bor (yoki avtobusni bos). '
                    'Har bir avtobus — bitta imkoniyat!',
                color: color,
              ),
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Bekatdagi avtobuslar (6 ta)',
          emoji: '🚏',
          color: theme.violet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            decoration: BoxDecoration(
              borderRadius: 16.circular,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.skyBottom, theme.grey.withValues(alpha: 0.5)],
                stops: const [0.6, 1],
              ),
            ),
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < 6; i++)
                  DragTarget<int>(
                    onAcceptWithDetails: (_) => board(i),
                    builder: (context, candidate, _) => _BusSpot(
                      number: i + 1,
                      color: buses[i].$2,
                      riding: _riding == i,
                      hovered: candidate.isNotEmpty,
                      done: found.contains('bus$i'),
                      onTap: () => board(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Leader extends StatelessWidget {
  final Color color;

  const _Leader({required this.color});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        decoration: BoxDecoration(
          color: theme.white,
          borderRadius: 22.circular,
          border: Border.all(color: color, width: 3),
          boxShadow: theme.lifted(color, depth: 0.5),
        ),
        child: Column(
          children: [
            const Emoji('🧑‍🏫', size: 56),
            Text('Sayr rahbari', style: theme.body(14)),
          ],
        ),
      ),
    );
  }
}

class _BusSpot extends StatelessWidget {
  final int number;
  final Color color;
  final bool riding;
  final bool hovered;
  final bool done;
  final VoidCallback onTap;

  const _BusSpot({
    required this.number,
    required this.color,
    required this.riding,
    required this.hovered,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          children: [
            SizedBox(
              height: 24,
              child: riding ? const Emoji('📯 Bip-bip!', size: 18) : null,
            ),
            AnimatedSlide(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutBack,
              offset: Offset(0, riding ? -0.12 : 0),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: hovered ? 1.1 : 1,
                child: CustomPaint(
                  size: const Size(96, 100),
                  painter: BusPainter(color: color, passenger: riding),
                ),
              ),
            ),
            6.height,
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? theme.green : theme.white,
                borderRadius: 10.circular,
                border: Border.all(color: done ? theme.green : theme.text, width: 2),
              ),
              child: Text(
                done ? '$number ✓' : '$number',
                style: theme.display(20, color: done ? theme.white : theme.text),
              ),
            ),
            8.height,
          ],
        ),
      ),
    );
  }
}
