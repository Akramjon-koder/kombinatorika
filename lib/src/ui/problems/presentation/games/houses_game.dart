import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/house_painter.dart';
import 'parts/pick_tile.dart';

/// (name, colour, emoji) of the three paints.
List<(String, Color, String)> get _paints => [
      ('Qizil', theme.red, '🟥'),
      ('Sariq', theme.yellow, '🟨'),
      ('Ko‘k', theme.blue, '🟦'),
    ];

const _houseCount = 6;

/// Problem 5 — paint the houses. Pick a paint bucket, tap the roof / wall /
/// window of a house. A house counts when it uses all three colours; equal
/// houses are outlined red so the child sees the repeat.
class HousesGame extends StatefulWidget {
  final Problem problem;

  const HousesGame({super.key, required this.problem});

  @override
  State<HousesGame> createState() => _HousesGameState();
}

class _HousesGameState extends State<HousesGame> {
  /// Paint index per part, per house.
  final List<Map<HousePart, int>> _houses = List.generate(_houseCount, (_) => {});
  int? _brush = 0;

  String? _keyOf(Map<HousePart, int> h) {
    if (h.length < 3) return null;
    return '${h[HousePart.roof]}${h[HousePart.wall]}${h[HousePart.window]}';
  }

  bool _isValid(Map<HousePart, int> h) => h.length == 3 && h.values.toSet().length == 3;

  void onTapPart(int house, HousePart part) {
    setState(() {
      if (_brush == null) {
        _houses[house].remove(part);
      } else {
        _houses[house][part] = _brush!;
      }
    });
    final h = _houses[house];
    if (h.length == 3 && !_isValid(h)) {
      context.read<ProblemBloc>().add(const ProblemHintShown(
            'Uychada uchala rang ham bo‘lsin: tom, devor va deraza — har xil rangda!',
          ));
    }
    _sync(house);
  }

  void _sync(int touched) {
    final paints = _paints;
    final seen = <String>{};
    final variants = <Variant>[];
    for (final h in _houses) {
      if (!_isValid(h)) continue;
      final key = _keyOf(h)!;
      if (!seen.add(key)) continue;
      variants.add(Variant(
        key: key,
        label: 'Tom ${paints[h[HousePart.roof]!].$1.toLowerCase()}, '
            'devor ${paints[h[HousePart.wall]!].$1.toLowerCase()}, '
            'deraza ${paints[h[HousePart.window]!].$1.toLowerCase()}',
        emojis: [
          paints[h[HousePart.roof]!].$3,
          paints[h[HousePart.wall]!].$3,
          paints[h[HousePart.window]!].$3,
        ],
      ));
    }
    final touchedKey = _isValid(_houses[touched]) ? _keyOf(_houses[touched]) : null;
    final twins = touchedKey == null
        ? 0
        : _houses.where((h) => _isValid(h) && _keyOf(h) == touchedKey).length;
    final bloc = context.read<ProblemBloc>();
    bloc.add(ProblemVariantsSynced(variants));
    if (twins > 1) {
      bloc.add(const ProblemHintShown(
        'Bu uycha boshqasi bilan bir xil bo‘lib qoldi! Boshqacha bo‘ya.',
        tone: MessageTone.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final paints = _paints;
    final counts = <String, int>{};
    for (final h in _houses) {
      final k = _isValid(h) ? _keyOf(h) : null;
      if (k != null) counts[k] = (counts[k] ?? 0) + 1;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfSection(
          title: 'Bo‘yoqlar',
          emoji: '🎨',
          color: color,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < 3; i++)
                PickTile(
                  picture: _Bucket(color: paints[i].$2),
                  label: paints[i].$1,
                  color: paints[i].$2,
                  selected: _brush == i,
                  width: 96,
                  onTap: () => setState(() => _brush = i),
                ),
              PickTile(
                picture: const Emoji('🧽', size: 40),
                label: 'O‘chirg‘ich',
                color: theme.grey,
                selected: _brush == null,
                width: 96,
                onTap: () => setState(() => _brush = null),
              ),
            ],
          ),
        ),
        16.height,
        ShelfSection(
          title: 'Uychalar ko‘chasi',
          emoji: '🏘️',
          color: theme.cyan,
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (var i = 0; i < _houseCount; i++)
                _HouseTile(
                  number: i + 1,
                  colors: {for (final e in _houses[i].entries) e.key: paints[e.value].$2},
                  state: !_isValid(_houses[i])
                      ? (_houses[i].length == 3 ? _HouseState.invalid : _HouseState.empty)
                      : (counts[_keyOf(_houses[i])]! > 1 ? _HouseState.twin : _HouseState.ok),
                  onTapPart: (part) => onTapPart(i, part),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _HouseState { empty, ok, twin, invalid }

class _HouseTile extends StatelessWidget {
  final int number;
  final Map<HousePart, Color> colors;
  final _HouseState state;
  final ValueChanged<HousePart> onTapPart;

  const _HouseTile({required this.number, required this.colors, required this.state, required this.onTapPart});

  @override
  Widget build(BuildContext context) {
    const size = Size(120, 130);
    final border = switch (state) {
      _HouseState.ok => theme.green,
      _HouseState.twin => theme.error,
      _HouseState.invalid => theme.amber,
      _HouseState.empty => theme.line,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: 10.all,
      decoration: BoxDecoration(
        color: theme.white,
        borderRadius: 20.circular,
        border: Border.all(color: border, width: state == _HouseState.empty ? 2 : 3.5),
        boxShadow: theme.lifted(border, depth: 0.4),
      ),
      child: Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTapDown: (d) {
                final part = HousePainter.hit(d.localPosition, size);
                if (part != null) onTapPart(part);
              },
              child: CustomPaint(size: size, painter: HousePainter(colors: colors, outline: theme.text)),
            ),
          ),
          6.height,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$number-uycha', style: theme.body(14)),
              if (state != _HouseState.empty) ...[
                6.width,
                Emoji(switch (state) {
                  _HouseState.ok => '✅',
                  _HouseState.twin => '👯',
                  _ => '⚠️',
                }, size: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Paint bucket with a drip.
class _Bucket extends StatelessWidget {
  final Color color;

  const _Bucket({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 44,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.grey, theme.white, theme.grey]),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10), top: Radius.circular(4)),
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: 48,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: 10.circular,
              border: Border.all(color: Color.lerp(color, theme.black, 0.25)!, width: 2),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            width: 8,
            height: 18,
            decoration: BoxDecoration(color: color, borderRadius: 6.circular),
          ),
        ),
      ],
    );
  }
}
