import 'dart:math';

import 'package:flutter/material.dart';

import '../../../theme/apptheme.dart';

/// Celebration burst: paper confetti + stars falling once over its child area.
/// Re-fires whenever [trigger] changes.
class Confetti extends StatefulWidget {
  final Object? trigger;

  const Confetti({super.key, required this.trigger});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  List<_Piece> _pieces = const [];

  @override
  void didUpdateWidget(covariant Confetti old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger != null) _fire();
  }

  @override
  void initState() {
    super.initState();
    if (widget.trigger != null) _fire();
  }

  void _fire() {
    final rnd = Random();
    final colors = [
      theme.pink, theme.secondary, theme.star, theme.green, theme.cyan, theme.violet,
    ];
    _pieces = List.generate(90, (i) {
      return _Piece(
        x: rnd.nextDouble(),
        delay: rnd.nextDouble() * 0.3,
        speed: 0.7 + rnd.nextDouble() * 0.6,
        drift: (rnd.nextDouble() - 0.5) * 0.3,
        spin: rnd.nextDouble() * 12,
        size: 6 + rnd.nextDouble() * 8,
        color: colors[i % colors.length],
        star: i % 7 == 0,
      );
    });
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => _c.isAnimating
            ? CustomPaint(painter: _ConfettiPainter(_pieces, _c.value), size: Size.infinite)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _Piece {
  final double x, delay, speed, drift, spin, size;
  final Color color;
  final bool star;

  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
    required this.star,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;

  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -20 + local * p.speed * (size.height + 60);
      final x = (p.x + p.drift * local + sin(local * 8 + p.spin) * 0.02) * size.width;
      final paint = Paint()..color = p.color.withValues(alpha: 1 - local * 0.6);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * local * 3);
      if (p.star) {
        canvas.drawPath(_star(p.size), paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  Path _star(double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.45;
      final a = -pi / 2 + i * pi / 5;
      final pt = Offset(cos(a) * rad, sin(a) * rad);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
