import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/money_extensions.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

/// Amount Akmal has to pay.
const _target = 10000;

/// (value, colour) of the three banknote kinds, biggest first.
List<(int, Color)> get _notes => [
      (5000, theme.pink),
      (2000, theme.blue),
      (1000, theme.violet),
    ];

/// 4th grade problem 5 — Akmal's wallet. Add / remove 5000, 2000 and 1000
/// so‘m notes; when the sum is exactly 10 000, "To‘lash" records the way
/// (how many notes of each kind). Paid ways are grouped by the number of
/// 5000 notes, which is the systematic way to count them.
class BanknotesGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const BanknotesGame({super.key, required this.problem});

  @override
  State<BanknotesGame> createState() => _BanknotesGameState();
}

class _BanknotesGameState extends State<BanknotesGame> {
  /// How many notes of each kind are on the counter (same order as [_notes]).
  final List<int> _counts = [0, 0, 0];

  /// Sum of the notes on the counter.
  int get _sum {
    final notes = _notes;
    var sum = 0;
    for (var i = 0; i < 3; i++) {
      sum += notes[i].$1 * _counts[i];
    }
    return sum;
  }

  /// Adds one note of kind [i]; refuses to go over 10 000.
  void onTapAdd(int i) {
    if (_sum + _notes[i].$1 > _target) {
      context.read<ProblemBloc>().add(ProblemHintShown(
            'Bunda ${(_sum + _notes[i].$1).spaced} so‘m bo‘lib, 10\u00A0000 dan oshib ketadi!',
          ));
      return;
    }
    setState(() => _counts[i]++);
  }

  /// Removes one note of kind [i].
  void onTapRemove(int i) {
    if (_counts[i] > 0) setState(() => _counts[i]--);
  }

  /// Records the exact payment and empties the counter.
  void onTapPay() {
    final notes = _notes;
    final parts = [
      for (var i = 0; i < 3; i++)
        if (_counts[i] > 0) '${notes[i].$1.spaced} × ${_counts[i]}',
    ];
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'm${_counts.join('-')}',
          label: parts.join(' + '),
          emojis: const ['💵'],
        )));
    setState(() => _counts.fillRange(0, 3, 0));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final notes = _notes;
    final sum = _sum;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    Widget note(int i, {double scale = 1}) => Container(
          width: 92 * scale,
          height: 46 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color.lerp(notes[i].$2, theme.white, 0.35)!, notes[i].$2]),
            borderRadius: (8 * scale).circular,
            border: Border.all(color: theme.white, width: 2 * scale),
            boxShadow: theme.lifted(notes[i].$2, depth: 0.25 * scale),
          ),
          child: Text(notes[i].$1.spaced, style: theme.display(19 * scale, color: theme.white)),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfSection(
          title: 'Qog‘oz pullar',
          emoji: '💵',
          color: color,
          child: Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              for (var i = 0; i < 3; i++)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    note(i, scale: 1.2),
                    10.height,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClayIconButton(icon: Icons.remove_rounded, color: theme.textMuted, onTap: () => onTapRemove(i)),
                        SizedBox(
                          width: 44,
                          child: Text('${_counts[i]}', textAlign: TextAlign.center, style: theme.display(26)),
                        ),
                        ClayIconButton(icon: Icons.add_rounded, color: notes[i].$2, onTap: () => onTapAdd(i)),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
        14.height,
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 300,
              padding: 14.all,
              decoration: BoxDecoration(
                color: theme.white,
                borderRadius: 18.circular,
                border: Border.all(color: sum == _target ? theme.green : theme.line, width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Emoji('👛', size: 28),
                      8.width,
                      Text('${sum.spaced} / ${_target.spaced}', style: theme.display(26, color: sum == _target ? theme.green : theme.text)),
                    ],
                  ),
                  8.height,
                  ClipRRect(
                    borderRadius: 10.circular,
                    child: LinearProgressIndicator(
                      value: sum / _target,
                      minHeight: 12,
                      color: sum == _target ? theme.green : color,
                      backgroundColor: theme.surfaceSubtle,
                    ),
                  ),
                ],
              ),
            ),
            ClayButton(
              color: theme.green,
              onTap: sum == _target ? onTapPay : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_rounded),
                  8.width,
                  const Text('To‘lash'),
                ],
              ),
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'To‘lov usullari',
          emoji: '🧾',
          color: theme.violet,
          child: found.isEmpty
              ? Text('Hali to‘lov yo‘q', style: theme.body(15, color: theme.textHint))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final v in [...found]..sort((a, b) => b.key.compareTo(a.key)))
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: 6.bottom,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: last == v.key ? theme.star.withValues(alpha: 0.4) : theme.white,
                          borderRadius: 12.circular,
                        ),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (var i = 0; i < 3; i++)
                              for (var k = 0; k < int.parse(v.key.substring(1).split('-')[i]); k++)
                                note(i, scale: 0.5),
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
