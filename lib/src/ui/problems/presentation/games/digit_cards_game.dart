import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

/// Captions of the three places of the number.
const _places = ['Yuzlar', 'O‘nlar', 'Birlar'];

/// 4th grade problem 6 — digit cards. Tap the cards 1, 2, 3, 4: each goes into
/// the next free place (hundreds → tens → ones). A used card can't be used
/// again, so digits never repeat. Found numbers are sorted into four columns
/// by their first digit.
class DigitCardsGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const DigitCardsGame({super.key, required this.problem});

  @override
  State<DigitCardsGame> createState() => _DigitCardsGameState();
}

class _DigitCardsGameState extends State<DigitCardsGame> {
  /// Digits placed so far (hundreds first).
  final List<int> _slots = [];

  /// Puts card [d] into the next free place; a full number becomes a variant.
  void onTapCard(int d) {
    if (_slots.length == 3) _slots.clear();
    if (_slots.contains(d)) return;
    setState(() => _slots.add(d));
    if (_slots.length < 3) return;
    final n = _slots.join();
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(key: 'n$n', label: n, emojis: const ['🔢'])));
  }

  /// Takes the card of place [i] (and every place after it) back.
  void onTapSlot(int i) {
    if (i < _slots.length) setState(() => _slots.removeRange(i, _slots.length));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    final full = _slots.length == 3;
    Widget card(int d, {double size = 70, bool faded = false}) => AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: faded ? 0.3 : 1,
          child: Container(
            width: size,
            height: size * 1.3,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.white,
              borderRadius: (size * 0.18).circular,
              border: Border.all(color: color, width: 3),
              boxShadow: theme.lifted(color, depth: 0.4),
            ),
            child: Text('$d', style: theme.display(size * 0.62, color: color)),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfSection(
          title: 'Kartochkalar (4 ta)',
          emoji: '🃏',
          color: color,
          child: Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              for (var d = 1; d <= 4; d++)
                GestureDetector(
                  onTap: () => onTapCard(d),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: card(d, faded: !full && _slots.contains(d)),
                  ),
                ),
            ],
          ),
        ),
        12.height,
        StepHint(
          text: full
              ? '${_slots.join()} soni tuzildi! Yangi son uchun kartochkani bos'
              : '${_places[_slots.length]} xonasiga qaysi raqam? Kartochkani bos',
          color: color,
        ),
        12.height,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: 6.horizontal,
                child: GestureDetector(
                  onTap: () => onTapSlot(i),
                  child: Column(
                    children: [
                      Text(_places[i], style: theme.body(14, color: theme.textMuted)),
                      6.height,
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack), child: c),
                        child: i < _slots.length
                            ? KeyedSubtree(key: ValueKey('c${_slots[i]}'), child: card(_slots[i], size: 80))
                            : Container(
                                key: const ValueKey('empty'),
                                width: 80,
                                height: 104,
                                decoration: BoxDecoration(
                                  color: theme.surfaceSubtle,
                                  borderRadius: 14.circular,
                                  border: Border.all(color: theme.slotBorder, width: 2.5),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Tuzilgan sonlar',
          emoji: '📒',
          color: theme.violet,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var d = 1; d <= 4; d++)
                Container(
                  width: 120,
                  padding: 8.all,
                  decoration: BoxDecoration(
                    color: theme.white,
                    borderRadius: 14.circular,
                    border: Border.all(color: theme.line, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text('$d _ _', style: theme.display(22, color: theme.textMuted)),
                      6.height,
                      for (final v in found.where((v) => v.label.startsWith('$d')).toList()
                        ..sort((a, b) => a.label.compareTo(b.label)))
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: 2.vertical,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: last == v.key ? theme.star.withValues(alpha: 0.45) : theme.transparent,
                            borderRadius: 8.circular,
                          ),
                          child: Text(v.label, style: theme.display(20, color: color)),
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
