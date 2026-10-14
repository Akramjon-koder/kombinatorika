import 'package:flutter/material.dart';

import '../../../../../extensions/size_extensions.dart';
import '../../../../../theme/apptheme.dart';

/// One cell of a "rows × columns" variants table (breakfast, snack bar):
/// a dashed "+" slot that pops into the variant's picture once found.
class TableSlot extends StatelessWidget {
  /// Cell width (height is 70 % of it).
  final double size;

  /// Whether the variant of this cell was found.
  final bool filled;

  /// Highlights the cell that was just found.
  final bool flash;

  /// Border / shadow colour when filled.
  final Color color;

  /// Picture of the variant, shown when [filled].
  final Widget child;

  const TableSlot({super.key, required this.size, required this.filled, required this.flash, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: size,
      height: size * 0.7,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? (flash ? theme.star.withValues(alpha: 0.45) : theme.white) : theme.surfaceSubtle,
        borderRadius: 14.circular,
        border: Border.all(color: filled ? color : theme.slotBorder, width: filled ? 3 : 2),
        boxShadow: filled ? theme.lifted(color, depth: 0.3) : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
        child: filled ? child : Icon(Icons.add_rounded, color: theme.slotBorder, size: 28),
      ),
    );
  }
}
