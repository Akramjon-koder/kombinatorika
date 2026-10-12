import 'package:flutter/material.dart';

import '../../../extensions/size_extensions.dart';
import '../../../theme/apptheme.dart';
import 'glass_card.dart';

/// Mascot emoji character with a cloud-like speech bubble above it, gently
/// bobbing. Used on the city map and next to each problem.
class Mascot extends StatefulWidget {
  final String emoji;
  final String text;
  final double size;

  const Mascot({super.key, required this.emoji, required this.text, this.size = 110});

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
          child: Container(
            key: ValueKey(widget.text),
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.white,
              borderRadius: 24.circular,
              boxShadow: theme.lifted(theme.primary, depth: 0.5),
            ),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: theme.body(15, color: theme.text, weight: FontWeight.w800),
            ),
          ),
        ),
        CustomPaint(size: const Size(24, 14), painter: _TailPainter()),
        AnimatedBuilder(
          animation: _bob,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -8 * Curves.easeInOut.transform(_bob.value)),
            child: child,
          ),
          child: Emoji(widget.emoji, size: widget.size),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.3, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = theme.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
