import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/rug_painter.dart';
import 'parts/pick_tile.dart';

/// (name, colour) of the three carpets.
List<(String, Color)> get _rugs => [
      ('Qizil', theme.red),
      ('Ko‘k', theme.blue),
      ('Kulrang', theme.grey),
    ];

/// Colour squares shown in the side-panel list.
const _squares = ['🟥', '🟦', '⬜'];

/// Problem 3 — carpet shop. Rolled carpets stand in the shop; the customer
/// picks two of different colours, pays, and they unroll in the customer's
/// room. Every purchase is kept as a shopping bag.
class CarpetsGame extends StatefulWidget {
  final Problem problem;

  const CarpetsGame({super.key, required this.problem});

  @override
  State<CarpetsGame> createState() => _CarpetsGameState();
}

class _CarpetsGameState extends State<CarpetsGame> {
  final List<int> _picked = [];
  List<int> _room = const [];

  void onTapRug(int i) {
    setState(() {
      if (_picked.contains(i)) {
        _picked.remove(i);
      } else if (_picked.length < 2) {
        _picked.add(i);
      } else {
        context.read<ProblemBloc>().add(const ProblemHintShown(
              'Xaridor faqat 2 ta gilam oladi. Avval bittasini qaytar!',
            ));
      }
    });
  }

  void onTapBuy() {
    final s = [..._picked]..sort();
    final rugs = _rugs;
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'r${s[0]}${s[1]}',
          label: '${rugs[s[0]].$1} + ${rugs[s[1]].$1.toLowerCase()}',
          emojis: [_squares[s[0]], _squares[s[1]]],
        )));
    setState(() {
      _room = s;
      _picked.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final rugs = _rugs;
    final bags = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            ShelfSection(
              title: 'Do‘kondagi gilamlar (3 ta)',
              emoji: '🧶',
              color: color,
              child: Wrap(
                spacing: 12,
                children: [
                  for (var i = 0; i < 3; i++)
                    PickTile(
                      picture: AnimatedRotation(
                        turns: _picked.contains(i) ? -0.03 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: CustomPaint(
                          size: const Size(60, 80),
                          painter: RolledRugPainter(rugs[i].$2),
                        ),
                      ),
                      label: rugs[i].$1,
                      color: rugs[i].$2,
                      selected: _picked.contains(i),
                      onTap: () => onTapRug(i),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Emoji('🧑‍🦱', size: 64),
                Text('Xaridor: ${_picked.length} / 2', style: theme.display(18)),
                8.height,
                ClayButton(
                  color: theme.green,
                  onTap: _picked.length == 2 ? onTapBuy : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag_rounded),
                      8.width,
                      const Text('Sotib olish'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Xaridorning uyi',
          emoji: '🏠',
          color: theme.woodDark,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.woodLight.withValues(alpha: 0.35),
              borderRadius: 16.circular,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_room.isEmpty)
                  Text('Gilamlar shu yerda yoyiladi', style: theme.body(16, color: theme.textHint)),
                for (final i in _room)
                  Padding(
                    padding: 10.horizontal,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('${_room.join()}$i'),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) => Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: v.clamp(0.08, 1.0),
                        child: child,
                      ),
                      child: CustomPaint(size: const Size(190, 110), painter: RugPainter(rugs[i].$2)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        14.height,
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final v in bags) _Bag(variant: v, rugs: rugs),
          ],
        ),
      ],
    );
  }
}

/// Paper shopping bag with two mini carpets peeking out.
class _Bag extends StatelessWidget {
  final Variant variant;
  final List<(String, Color)> rugs;

  const _Bag({required this.variant, required this.rugs});

  @override
  Widget build(BuildContext context) {
    final a = int.parse(variant.key[1]), b = int.parse(variant.key[2]);
    return Container(
      width: 130,
      padding: 10.all,
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: 14.circular,
        border: Border.all(color: theme.woodLight, width: 2),
        boxShadow: theme.lifted(theme.woodDark, depth: 0.3),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(size: const Size(26, 40), painter: RolledRugPainter(rugs[a].$2)),
              6.width,
              CustomPaint(size: const Size(26, 40), painter: RolledRugPainter(rugs[b].$2)),
            ],
          ),
          4.height,
          Text(variant.label, textAlign: TextAlign.center, style: theme.body(13)),
        ],
      ),
    );
  }
}
