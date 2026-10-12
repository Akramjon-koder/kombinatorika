import 'package:flutter/material.dart';

import '../../../../../extensions/size_extensions.dart';
import '../../../../../theme/apptheme.dart';
import '../../../../collectitive/widgets/glass_card.dart';

/// Selectable 3D object tile (a shirt on a hanger, a bowl, a juice box…):
/// white card, picture, caption, number disc. Bounces when selected and
/// shows a "done" tick when [done].
class PickTile extends StatefulWidget {
  final Widget picture;
  final String label;
  final Color color;
  final bool selected;
  final bool done;
  final String? badge;
  final VoidCallback? onTap;
  final double width;

  const PickTile({
    super.key,
    required this.picture,
    required this.label,
    required this.color,
    required this.onTap,
    this.selected = false,
    this.done = false,
    this.badge,
    this.width = 118,
  });

  @override
  State<PickTile> createState() => _PickTileState();
}

class _PickTileState extends State<PickTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return MouseRegion(
      cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          scale: sel ? 1.08 : (_hover ? 1.04 : 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: widget.width,
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            decoration: BoxDecoration(
              color: sel ? Color.lerp(theme.white, widget.color, 0.14) : theme.white,
              borderRadius: 20.circular,
              border: Border.all(
                color: sel ? widget.color : theme.line,
                width: sel ? 3.5 : 2,
              ),
              boxShadow: theme.lifted(widget.color, depth: sel ? 0.8 : 0.4),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: widget.width * 0.62, child: Center(child: widget.picture)),
                    6.height,
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: theme.body(14, color: theme.text, weight: FontWeight.w800),
                    ),
                  ],
                ),
                if (widget.badge != null)
                  Positioned(
                    left: -2,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: widget.color, borderRadius: 12.circular),
                      child: Text(widget.badge!, style: theme.display(15, color: theme.white)),
                    ),
                  ),
                if (widget.done)
                  Positioned(
                    right: -4,
                    top: -6,
                    child: Container(
                      padding: 2.all,
                      decoration: BoxDecoration(color: theme.green, shape: BoxShape.circle),
                      child: Icon(Icons.check_rounded, size: 16, color: theme.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tinted rounded section with an icon disc + title ("Ko'ylaklar (3 ta)").
class ShelfSection extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final Widget child;

  const ShelfSection({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: 22.circular,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PillTitle(text: title, color: color, leading: Emoji(emoji, size: 18)),
          12.height,
          child,
        ],
      ),
    );
  }
}

/// Small rounded instruction line under a game ("Endi garnirni tanla").
class StepHint extends StatelessWidget {
  final String text;
  final Color color;

  const StepHint({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: 16.circular,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Emoji('👉', size: 18),
            8.width,
            Flexible(child: Text(text, style: theme.body(15, color: color))),
          ],
        ),
      ),
    );
  }
}
