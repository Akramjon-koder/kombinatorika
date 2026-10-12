import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/routes.dart';
import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../model/problem.dart';

/// "Barakalla!" — earned stars, the formula and where to go next.
Future<void> showSolvedDialog(BuildContext context, Problem problem, int stars) =>
    showDialog<void>(
      context: context,
      barrierColor: theme.text.withValues(alpha: 0.35),
      builder: (dialogContext) => Dialog(
        backgroundColor: theme.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassCard(
            color: theme.white,
            tint: theme.green,
            padding: 28.all,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StarsPop(stars: stars),
                8.height,
                Text(Words.solvedTitle.tr(), style: theme.display(40, color: theme.green)),
                Text(Words.solvedSub.tr(), style: theme.body(17, color: theme.textMuted)),
                16.height,
                Container(
                  width: double.infinity,
                  padding: 16.all,
                  decoration: BoxDecoration(
                    color: problem.color.withValues(alpha: 0.1),
                    borderRadius: 20.circular,
                  ),
                  child: Column(
                    children: [
                      Text(problem.formula, style: theme.display(34, color: problem.color)),
                      6.height,
                      Text(
                        problem.explanation,
                        textAlign: TextAlign.center,
                        style: theme.body(15, color: theme.text),
                      ),
                    ],
                  ),
                ),
                22.height,
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ClayButton(
                      color: theme.primary,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        context.go(Routes.city);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_rounded),
                          8.width,
                          Text(Words.toCity.tr()),
                        ],
                      ),
                    ),
                    if (problem.id < Problem.all.length)
                      ClayButton(
                        color: theme.green,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          context.go(Routes.problemOf(problem.id + 1));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Words.nextProblem.tr()),
                            8.width,
                            const Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                  ],
                ),
                6.height,
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(Words.close.tr(), style: theme.body(15, color: theme.textMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

/// Three stars popping in one after another.
class _StarsPop extends StatelessWidget {
  final int stars;

  const _StarsPop({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 500 + i * 250),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.scale(scale: v, child: child),
            child: Padding(
              padding: EdgeInsets.only(bottom: i == 1 ? 16 : 0),
              child: Icon(
                Icons.star_rounded,
                size: i == 1 ? 84 : 64,
                color: i < stars ? theme.star : theme.line,
                shadows: [
                  Shadow(color: theme.secondary.withValues(alpha: 0.5), offset: const Offset(0, 4)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
