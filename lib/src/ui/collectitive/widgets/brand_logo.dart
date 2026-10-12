import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../constants/string.dart';
import '../../../theme/apptheme.dart';

/// Bubbly "Kombinatorika shahri" wordmark: thick white outline + coloured fill
/// + drop shadow, like a sticker. [scale] 1 = hero size on the welcome screen.
class BrandLogo extends StatelessWidget {
  final double scale;
  final bool slogan;

  const BrandLogo({super.key, this.scale = 1, this.slogan = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StickerText(Words.brandTitle.tr(), size: 64 * scale, color: theme.primary),
        Transform.translate(
          offset: Offset(0, -10 * scale),
          child: Transform.rotate(
            angle: -0.03,
            child: StickerText(
              Words.brandCity.tr(),
              size: 60 * scale,
              color: theme.secondary,
            ),
          ),
        ),
        if (slogan)
          Text(
            Words.brandSlogan.tr(),
            textAlign: TextAlign.center,
            style: theme.body(18 * scale, color: theme.text, weight: FontWeight.w800),
          ),
      ],
    );
  }
}

/// Text with a thick white outline and a coloured drop shadow.
class StickerText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;

  const StickerText(this.text, {super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final base = theme.display(size, color: color, weight: FontWeight.w800);
    return Stack(
      children: [
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.16
              ..strokeJoin = StrokeJoin.round
              ..color = theme.white,
            shadows: [
              Shadow(
                color: Color.lerp(color, theme.black, 0.45)!.withValues(alpha: 0.45),
                offset: Offset(0, size * 0.08),
                blurRadius: size * 0.06,
              ),
            ],
          ),
        ),
        Text(
          text,
          style: base.copyWith(
            shadows: [
              Shadow(
                color: Color.lerp(color, theme.black, 0.3)!,
                offset: Offset(0, size * 0.04),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
