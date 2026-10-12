import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'parts/pick_tile.dart';

const _insects = [('🪲', 'Qo‘ng‘iz'), ('🦋', 'Kapalak'), ('🐞', 'Xonqizi'), ('🪰', 'Pashsha')];

/// Problem 2 — insect cards. A blank card is split by a diagonal (like in the
/// worksheet picture); drop an insect into each half and put the card into
/// the album. A flipped card is the same card — the bloc catches it.
class InsectCardsGame extends StatefulWidget {
  final Problem problem;

  const InsectCardsGame({super.key, required this.problem});

  @override
  State<InsectCardsGame> createState() => _InsectCardsGameState();
}

class _InsectCardsGameState extends State<InsectCardsGame> {
  int? _top;
  int? _bottom;

  void onTapInsect(int i) {
    if (_top == i || _bottom == i) {
      context.read<ProblemBloc>().add(const ProblemHintShown(
            'Bitta kartochkada ikkita bir xil hasharot bo‘lmaydi!',
          ));
      return;
    }
    setState(() {
      if (_top == null) {
        _top = i;
      } else if (_bottom == null) {
        _bottom = i;
      } else {
        _bottom = i;
      }
    });
  }

  void onTapPut() {
    final a = _top!, b = _bottom!;
    final sorted = [a, b]..sort();
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: 'c${sorted[0]}${sorted[1]}',
          label: '${_insects[sorted[0]].$2} + ${_insects[sorted[1]].$2.toLowerCase()}',
          emojis: [_insects[sorted[0]].$1, _insects[sorted[1]].$1],
        )));
    setState(() {
      _top = null;
      _bottom = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    final ready = _top != null && _bottom != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ShelfSection(
              title: 'Hasharotlar (4 ta)',
              emoji: '🐞',
              color: color,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < 4; i++)
                    PickTile(
                      picture: Emoji(_insects[i].$1, size: 50),
                      label: _insects[i].$2,
                      color: color,
                      width: 104,
                      selected: _top == i || _bottom == i,
                      onTap: () => onTapInsect(i),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SplitCard(
                  top: _top == null ? null : _insects[_top!].$1,
                  bottom: _bottom == null ? null : _insects[_bottom!].$1,
                  size: 170,
                  color: color,
                  onTapTop: () => setState(() => _top = null),
                  onTapBottom: () => setState(() => _bottom = null),
                ),
                12.height,
                ClayButton(
                  color: color,
                  onTap: ready ? onTapPut : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_album_rounded),
                      8.width,
                      const Text('Albomga qo‘yish'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Kartochkalar albomi',
          emoji: '📒',
          color: theme.violet,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final v in found)
                SplitCard(top: v.emojis[0], bottom: v.emojis[1], size: 92, color: color),
              _EmptyCard(size: 92),
            ],
          ),
        ),
      ],
    );
  }
}

/// Square card cut by a diagonal; [top] sits in the upper-right half,
/// [bottom] in the lower-left half.
class SplitCard extends StatelessWidget {
  final String? top;
  final String? bottom;
  final double size;
  final Color color;
  final VoidCallback? onTapTop;
  final VoidCallback? onTapBottom;

  const SplitCard({
    super.key,
    required this.top,
    required this.bottom,
    required this.size,
    required this.color,
    this.onTapTop,
    this.onTapBottom,
  });

  @override
  Widget build(BuildContext context) {
    Widget slot(String? e, Alignment a, VoidCallback? onTap) => Align(
          alignment: a,
          child: GestureDetector(
            onTap: e == null ? null : onTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, an) => ScaleTransition(
                scale: CurvedAnimation(parent: an, curve: Curves.elasticOut),
                child: child,
              ),
              child: e == null
                  ? Text('?', key: const ValueKey('?'), style: theme.display(size * 0.22, color: theme.slotBorder))
                  : Emoji(e, key: ValueKey(e), size: size * 0.3),
            ),
          ),
        );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.white,
        borderRadius: (size * 0.08).circular,
        border: Border.all(color: color, width: 3),
        boxShadow: theme.lifted(color, depth: 0.5),
      ),
      child: CustomPaint(
        painter: _DiagonalPainter(color),
        child: Stack(
          children: [
            slot(top, const Alignment(0.5, -0.5), onTapTop),
            slot(bottom, const Alignment(-0.5, 0.5), onTapBottom),
          ],
        ),
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  final Color color;

  _DiagonalPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width * 0.04, size.height * 0.04),
      Offset(size.width * 0.96, size.height * 0.96),
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _DiagonalPainter old) => old.color != color;
}

class _EmptyCard extends StatelessWidget {
  final double size;

  const _EmptyCard({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: 10.circular,
        border: Border.all(color: theme.slotBorder, width: 2.5),
        color: theme.surfaceSubtle,
      ),
      child: Icon(Icons.add_rounded, color: theme.slotBorder, size: 36),
    );
  }
}
