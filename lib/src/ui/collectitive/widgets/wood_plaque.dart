import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../constants/string.dart';
import '../../../extensions/size_extensions.dart';
import '../../../theme/apptheme.dart';
import 'glass_card.dart';

/// Hanging wooden shop sign with a candy ribbon — the title of each location
/// (see `resources/13.jpg`). Two ropes come down from above.
class WoodPlaque extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final bool compact;

  const WoodPlaque({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 26.0 : 40.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          SizedBox(
            width: 300,
            height: 16,
            child: CustomPaint(painter: _RopePainter()),
          ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: compact ? 14 : 20),
              padding: EdgeInsets.fromLTRB(28, compact ? 8 : 12, 28, compact ? 20 : 28),
              decoration: BoxDecoration(
                borderRadius: 28.circular,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.woodLight, theme.wood],
                ),
                border: Border.all(color: theme.woodDark, width: 3),
                boxShadow: theme.lifted(theme.woodDark),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: compact ? 4 : 8),
                decoration: BoxDecoration(
                  color: theme.paper,
                  borderRadius: 20.circular,
                  border: Border.all(color: theme.woodDark.withValues(alpha: 0.4), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Emoji(emoji, size: titleSize * 0.9),
                    12.width,
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.display(titleSize, color: theme.primary),
                      ),
                    ),
                    12.width,
                    Emoji(emoji, size: titleSize * 0.9),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: compact ? 3 : 6),
              decoration: BoxDecoration(
                color: theme.pink,
                borderRadius: 30.circular,
                border: Border.all(color: theme.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(theme.pink, theme.black, 0.3)!,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                Words.problemBadge.tr(),
                style: theme.display(compact ? 15 : 20, color: theme.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.woodDark
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.12, 0), Offset(size.width * 0.12, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.88, 0), Offset(size.width * 0.88, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
