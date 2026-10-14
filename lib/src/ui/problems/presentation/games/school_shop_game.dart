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

/// Money in Aziz's pocket.
const _budget = 10000;

/// (emoji, name, price) of the shop items, as in the worksheet table.
const _items = [
  ('✏️', 'Qalam', 1500),
  ('📓', 'Daftar', 3000),
  ('📏', 'Chizg‘ich', 2000),
  ('🖍️', 'Rangli qalamlar to‘plami', 5000),
  ('👝', 'Penal', 6000),
];

/// 4th grade problem 10 — school shop. Put three different items into the
/// basket; "Sotib olish" works only when the total fits into 10 000 so‘m —
/// otherwise the cashier says the money is not enough. Every purchase prints
/// a receipt.
class SchoolShopGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const SchoolShopGame({super.key, required this.problem});

  @override
  State<SchoolShopGame> createState() => _SchoolShopGameState();
}

class _SchoolShopGameState extends State<SchoolShopGame> {
  /// Items in the basket (at most three, all different).
  final List<int> _basket = [];

  /// Total price of the basket.
  int get _sum => _basket.fold<int>(0, (s, i) => s + _items[i].$3);

  /// Puts item [i] into the basket or takes it out.
  void onTapItem(int i) {
    if (_basket.contains(i)) {
      setState(() => _basket.remove(i));
    } else if (_basket.length < 3) {
      setState(() => _basket.add(i));
    } else {
      context.read<ProblemBloc>().add(const ProblemHintShown('Aziz faqat 3 ta narsa oladi. Avval bittasini qaytar!'));
    }
  }

  /// Buys the basket if it fits into the budget.
  void onTapBuy() {
    final sum = _sum;
    if (sum > _budget) {
      context.read<ProblemBloc>().add(ProblemHintShown(
            'Jami ${sum.som} — pul yetmaydi! Bu xaridni qilib bo‘lmaydi.',
            tone: MessageTone.error,
          ));
      return;
    }
    final s = [..._basket]..sort();
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'shop${s.join()}',
          label: '${s.map((i) => _items[i].$2).join(' + ')} = ${sum.som}',
          emojis: [for (final i in s) _items[i].$1],
        )));
    setState(_basket.clear);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final sum = _sum;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final last = context.select<ProblemBloc, String?>((b) => b.state.highlight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfSection(
          title: 'Maktab do‘koni',
          emoji: '🏪',
          color: color,
          child: Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              for (var i = 0; i < _items.length; i++)
                PickTile(
                  picture: Emoji(_items[i].$1, size: 48),
                  label: _items[i].$2,
                  badge: _items[i].$3.spaced,
                  color: color,
                  width: 132,
                  selected: _basket.contains(i),
                  onTap: () => onTapItem(i),
                ),
            ],
          ),
        ),
        16.height,
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 280),
              padding: 14.all,
              decoration: BoxDecoration(
                color: theme.white,
                borderRadius: 18.circular,
                border: Border.all(color: sum > _budget ? theme.error : theme.line, width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Emoji('🧺', size: 28),
                      8.width,
                      Text('Savat: ${_basket.length} / 3', style: theme.display(20)),
                      12.width,
                      for (final i in _basket) Emoji(_items[i].$1, size: 24),
                    ],
                  ),
                  6.height,
                  Text(
                    'Jami: ${sum.som}  (cho‘ntakda ${_budget.som})',
                    style: theme.body(15, color: sum > _budget ? theme.error : theme.textMuted),
                  ),
                ],
              ),
            ),
            ClayButton(
              color: theme.green,
              onTap: _basket.length == 3 ? onTapBuy : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_checkout_rounded),
                  8.width,
                  const Text('Sotib olish'),
                ],
              ),
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Cheklar',
          emoji: '🧾',
          color: theme.violet,
          child: found.isEmpty
              ? Text('Hali xarid yo‘q', style: theme.body(15, color: theme.textHint))
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final v in found)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 210,
                        padding: 10.all,
                        decoration: BoxDecoration(
                          color: last == v.key ? theme.star.withValues(alpha: 0.4) : theme.paper,
                          borderRadius: 10.circular,
                          border: Border.all(color: theme.woodLight, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final ch in v.key.substring(4).split(''))
                              Row(
                                children: [
                                  Emoji(_items[int.parse(ch)].$1, size: 18),
                                  6.width,
                                  Expanded(
                                    child: Text(
                                      _items[int.parse(ch)].$2,
                                      style: theme.body(13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(_items[int.parse(ch)].$3.spaced, style: theme.body(13)),
                                ],
                              ),
                            Divider(color: theme.woodLight),
                            Text(
                              'Jami: ${v.key.substring(4).split('').fold<int>(0, (s, ch) => s + _items[int.parse(ch)].$3).som}',
                              style: theme.display(16, color: color),
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
