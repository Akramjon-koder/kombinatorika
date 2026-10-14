import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

/// (name, flower emoji) of the three bulbs.
const _bulbs = [('Sumbula', '🪻'), ('Krokus', '🌸'), ('Lola', '🌷')];

/// 4th grade problem 2 — flower pots. Pick a bulb, then a pot hole: two holes
/// of the double pot and one of the single pot. "Ekish" makes the flowers
/// bloom. Swapping the two flowers of the double pot is the same planting —
/// so a variant is identified by the bulb of the single pot.
class FlowerPotsGame extends StatefulWidget {
  /// Problem being played.
  final Problem problem;

  const FlowerPotsGame({super.key, required this.problem});

  @override
  State<FlowerPotsGame> createState() => _FlowerPotsGameState();
}

class _FlowerPotsGameState extends State<FlowerPotsGame> {
  /// Bulb in each hole: 0, 1 — double pot, 2 — single pot.
  final List<int?> _holes = [null, null, null];

  /// Bulb picked in the tray, waiting for a hole.
  int? _picked;

  /// True after "Ekish": flowers are shown in bloom.
  bool _bloomed = false;

  /// Clears the pots after a bloom so a new planting can start.
  void _clearBloom() {
    if (!_bloomed) return;
    _bloomed = false;
    _holes.fillRange(0, 3, null);
  }

  /// Picks / un-picks a bulb in the tray.
  void onTapBulb(int b) {
    setState(() {
      _clearBloom();
      _picked = _picked == b ? null : b;
    });
  }

  /// Plants the picked bulb into [hole], or takes a planted bulb back out.
  void onTapHole(int hole) {
    setState(() {
      _clearBloom();
      if (_picked == null) {
        _holes[hole] = null;
        return;
      }
      final from = _holes.indexOf(_picked);
      if (from != -1) _holes[from] = null;
      _holes[hole] = _picked;
      _picked = null;
    });
  }

  /// Records the planting and lets the flowers bloom.
  void onTapPlant() {
    final single = _holes[2]!;
    final pair = [_holes[0]!, _holes[1]!]..sort();
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'pot$single',
          label: 'Bittalikda: ${_bulbs[single].$1.toLowerCase()}; qo‘shaloqda: '
              '${_bulbs[pair[0]].$1.toLowerCase()} + ${_bulbs[pair[1]].$1.toLowerCase()}',
          emojis: [_bulbs[pair[0]].$2, _bulbs[pair[1]].$2, _bulbs[single].$2],
        )));
    setState(() => _bloomed = true);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final full = !_holes.contains(null);
    Widget hole(int i) => GestureDetector(
          onTap: () => onTapHole(i),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 82,
              height: 92,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: _picked != null && _holes[i] == null ? theme.star.withValues(alpha: 0.25) : theme.transparent,
                borderRadius: 16.circular,
                border: Border.all(color: _holes[i] == null ? theme.slotBorder : theme.transparent, width: 2),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
                child: _holes[i] == null
                    ? Icon(Icons.add_circle_outline_rounded, key: const ValueKey('empty'), color: theme.slotBorder, size: 34)
                    : Column(
                        key: ValueKey('${_holes[i]}$_bloomed'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Emoji(_bloomed ? _bulbs[_holes[i]!].$2 : '🧅', size: _bloomed ? 54 : 38),
                          Text(_bulbs[_holes[i]!].$1, style: theme.body(13)),
                        ],
                      ),
              ),
            ),
          ),
        );
    Widget pot({required int holes, required List<int> ids}) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [for (final i in ids) hole(i)]),
            CustomPaint(
              size: Size(ids.length * 82.0 + 16, 64),
              painter: _PotPainter(color: holes == 2 ? theme.red : theme.greenObj, sections: holes),
            ),
            8.height,
            Text(holes == 2 ? 'Qo‘shaloq tuvak' : 'Bittalik tuvak', style: theme.display(17)),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfSection(
          title: 'Gul piyozlari (3 ta)',
          emoji: '🧅',
          color: color,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var b = 0; b < 3; b++)
                PickTile(
                  picture: Emoji(_bulbs[b].$2, size: 50),
                  label: _bulbs[b].$1,
                  color: color,
                  selected: _picked == b,
                  done: !_bloomed && _holes.contains(b),
                  onTap: () => onTapBulb(b),
                ),
            ],
          ),
        ),
        12.height,
        StepHint(
          text: _bloomed
              ? 'Gullar ochildi! Boshqacha ekish uchun piyozni yana tanla'
              : _picked != null
                  ? '${_bulbs[_picked!].$1} tanlandi — endi tuvakdagi bo‘sh joyni bos'
                  : full
                      ? 'Hamma piyoz ekildi — «Ekish» tugmasini bos'
                      : 'Piyozni tanla, keyin tuvakni bos',
          color: color,
        ),
        14.height,
        Wrap(
          spacing: 30,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            pot(holes: 2, ids: const [0, 1]),
            pot(holes: 1, ids: const [2]),
            ClayButton(
              color: theme.green,
              onTap: full && !_bloomed ? onTapPlant : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Emoji('🌱', size: 22),
                  8.width,
                  const Text('Ekish'),
                ],
              ),
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Mastura ekkan usullar',
          emoji: '🪴',
          color: theme.violet,
          child: found.isEmpty
              ? Text('Hali hech narsa ekilmadi', style: theme.body(15, color: theme.textHint))
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final v in found)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.white,
                          borderRadius: 16.circular,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Double pot's pair | single pot's flower.
                            Emoji(v.emojis[0], size: 30),
                            Emoji(v.emojis[1], size: 30),
                            Container(width: 2, height: 30, margin: 8.horizontal, color: theme.line),
                            Emoji(v.emojis[2], size: 30),
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

/// Clay flower pot seen from the front: rim, tapered body and soil; a double
/// pot has a divider between its two [sections].
class _PotPainter extends CustomPainter {
  /// Clay colour.
  final Color color;

  /// Number of planting holes (1 or 2).
  final int sections;

  _PotPainter({required this.color, required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = Color.lerp(color, theme.black, 0.25)!;
    final body = Path()
      ..moveTo(w * 0.05, h * 0.22)
      ..lineTo(w * 0.95, h * 0.22)
      ..lineTo(w * 0.85, h)
      ..lineTo(w * 0.15, h)
      ..close();
    canvas.drawPath(
      body,
      Paint()..shader = LinearGradient(colors: [Color.lerp(color, theme.white, 0.2)!, color, dark]).createShader(Offset.zero & size),
    );
    canvas.drawRRect(RRect.fromLTRBR(0, 0, w, h * 0.3, const Radius.circular(8)), Paint()..color = dark);
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.03, h * 0.04, w * 0.97, h * 0.16, const Radius.circular(6)),
      Paint()..color = theme.woodDark,
    );
    if (sections == 2) {
      canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), Paint()
        ..color = theme.black.withValues(alpha: 0.25)
        ..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(covariant _PotPainter old) => old.color != color || old.sections != sections;
}
