import 'package:flutter/material.dart';

import '../../../extensions/size_extensions.dart';
import '../../../theme/apptheme.dart';

/// Chunky "clay" 3D button: a darker base slab under a glossy face that sinks
/// on press. Shared by every screen so all CTAs feel like the same toy.
class ClayButton extends StatefulWidget {
  final Color color;
  final VoidCallback? onTap;
  final Widget child;
  final double radius;
  final double depth;
  final EdgeInsets padding;

  const ClayButton({
    super.key,
    required this.color,
    required this.onTap,
    required this.child,
    this.radius = 22,
    this.depth = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final color = enabled ? widget.color : theme.textHint;
    final base = Color.lerp(color, theme.black, 0.28)!;
    final sink = _down ? widget.depth - 1 : 0.0;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onTap!();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          margin: EdgeInsets.only(top: sink, bottom: widget.depth - sink),
          decoration: BoxDecoration(
            color: base,
            borderRadius: widget.radius.circular,
            boxShadow: [
              BoxShadow(
                color: base,
                offset: Offset(0, widget.depth - sink),
              ),
              BoxShadow(
                color: theme.black.withValues(alpha: _down ? 0.08 : 0.18),
                offset: Offset(0, widget.depth - sink + 6),
                blurRadius: 14,
              ),
            ],
          ),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: widget.radius.circular,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(color, theme.white, 0.28)!,
                  color,
                ],
              ),
              border: Border.all(
                color: theme.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: DefaultTextStyle.merge(
              style: theme.display(20, color: theme.white),
              child: IconTheme.merge(
                data: IconThemeData(color: theme.white),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small round clay icon button (back, settings, prev/next).
class ClayIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? tooltip;

  const ClayIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = ClayButton(
      color: color ?? theme.primary,
      onTap: onTap,
      radius: 18,
      depth: 4,
      padding: 10.all,
      child: Icon(icon, size: 24),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
