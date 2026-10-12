import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/routes.dart';
import '../../../constants/string.dart';
import '../../../extensions/size_extensions.dart';
import '../../../network/progress_repository.dart';
import '../../../theme/apptheme.dart';
import '../../collectitive/widgets/brand_logo.dart';
import '../../collectitive/widgets/clay_button.dart';
import '../../collectitive/widgets/glass_card.dart';
import '../../collectitive/widgets/scene_background.dart';
import 'dialogs/sign_in_dialog.dart';

/// Entry screen (see `resources/11.jpg`): the city street, a cloud with the
/// wordmark and two big role buttons — learner and teacher.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> onTapLearner(BuildContext context) async {
    final ok = await showSignInDialog(context);
    if (ok == true && context.mounted) context.go(Routes.city);
  }

  /// The teacher area is shared-device: sign the learner out first so the
  /// teacher's "try it" runs are not saved into a child's results.
  Future<void> onTapTeacher(BuildContext context) async {
    await context.read<ProgressRepository>().signOut();
    if (context.mounted) context.go(Routes.teacher);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SceneBackground(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth > 900;
            return Stack(
              children: [
                if (wide) ...[
                  const Positioned(left: 30, bottom: 30, child: _Kid(emoji: '🧒🏻', flip: false)),
                  const Positioned(right: 30, bottom: 30, child: _Kid(emoji: '👧🏻', flip: true)),
                ],
                Center(
                  child: SingleChildScrollView(
                    padding: 24.all,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LogoCloud(scale: wide ? 1 : 0.7),
                        (wide ? 60 : 32).height,
                        Wrap(
                          spacing: 28,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            _RoleButton(
                              color: theme.green,
                              icon: Icons.person_rounded,
                              title: Words.roleLearner.tr(),
                              subtitle: Words.roleLearnerSub.tr(),
                              onTap: () => onTapLearner(context),
                            ),
                            _RoleButton(
                              color: theme.violet,
                              icon: Icons.co_present_rounded,
                              title: Words.roleTeacher.tr(),
                              subtitle: Words.roleTeacherSub.tr(),
                              onTap: () => onTapTeacher(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Wordmark sitting on a big puffy cloud.
class _LogoCloud extends StatelessWidget {
  final double scale;

  const _LogoCloud({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: CustomPaint(painter: _CloudPainter())),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 70 * scale, vertical: 46 * scale),
          child: BrandLogo(scale: scale),
        ),
      ],
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final shadow = Paint()
      ..color = theme.primary.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final fill = Paint()..color = theme.white;
    final bubbles = [
      Rect.fromLTWH(w * 0.06, h * 0.22, w * 0.88, h * 0.62),
      Rect.fromCircle(center: Offset(w * 0.25, h * 0.28), radius: h * 0.24),
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.2), radius: h * 0.26),
      Rect.fromCircle(center: Offset(w * 0.75, h * 0.3), radius: h * 0.22),
      Rect.fromCircle(center: Offset(w * 0.1, h * 0.6), radius: h * 0.2),
      Rect.fromCircle(center: Offset(w * 0.9, h * 0.6), radius: h * 0.2),
      Rect.fromCircle(center: Offset(w * 0.35, h * 0.85), radius: h * 0.16),
      Rect.fromCircle(center: Offset(w * 0.65, h * 0.85), radius: h * 0.16),
    ];
    for (final r in bubbles) {
      canvas.drawRRect(RRect.fromRectAndRadius(r.translate(0, 10), Radius.circular(h)), shadow);
    }
    for (final r in bubbles) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(h)), fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Big chunky role button with an icon, title and subtitle.
class _RoleButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: ClayButton(
        color: color,
        onTap: onTap,
        radius: 34,
        depth: 9,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40),
                14.width,
                Text(title, style: theme.display(34, color: theme.white)),
              ],
            ),
            10.height,
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.body(15, color: theme.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Waving kid standing on the street corner.
class _Kid extends StatefulWidget {
  final String emoji;
  final bool flip;

  const _Kid({required this.emoji, required this.flip});

  @override
  State<_Kid> createState() => _KidState();
}

class _KidState extends State<_Kid> with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wave,
      builder: (context, child) => Transform.rotate(
        angle: (widget.flip ? -1 : 1) * 0.06 * (_wave.value - 0.5),
        alignment: Alignment.bottomCenter,
        child: child,
      ),
      child: Column(
        children: [
          Emoji(widget.flip ? '👋' : '🎒', size: 54),
          Emoji(widget.emoji, size: 190),
        ],
      ),
    );
  }
}
