import 'package:flutter/material.dart';

import '../../../extensions/size_extensions.dart';
import '../../../theme/apptheme.dart';

/// Frosted white rounded panel with a soft lifted shadow — the base surface of
/// every content block (problem card, side panel, header pills).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? tint;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 26,
    this.tint,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.glass,
        borderRadius: radius.circular,
        border: Border.all(color: theme.white, width: 2),
        boxShadow: theme.lifted(tint ?? theme.primary, depth: 0.7),
      ),
      child: child,
    );
  }
}

/// Coloured pill title ("1-masala", "Topilgan variantlar") with an icon disc.
class PillTitle extends StatelessWidget {
  final String text;
  final Color color;
  final Widget leading;

  const PillTitle({
    super.key,
    required this.text,
    required this.color,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 18, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, theme.white, 0.25)!],
        ),
        borderRadius: 30.circular,
        boxShadow: [
          BoxShadow(
            color: Color.lerp(color, theme.black, 0.3)!,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: theme.white, shape: BoxShape.circle),
            child: leading,
          ),
          10.width,
          Flexible(
            child: Text(
              text,
              style: theme.display(19, color: theme.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Emoji rendered at a given size (keeps emoji sizing consistent).
class Emoji extends StatelessWidget {
  final String emoji;
  final double size;

  const Emoji(this.emoji, {super.key, this.size = 28});

  @override
  Widget build(BuildContext context) => Text(
        emoji,
        style: TextStyle(fontSize: size, height: 1.1, fontFamily: theme.emojiFont),
        textAlign: TextAlign.center,
      );
}
