import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/routes.dart';
import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/model/grade.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../../problems/model/problem.dart';

/// Every problem with its answer, formula and explanation, grouped by grade.
class AnswerKey extends StatelessWidget {
  /// Shown grade; `null` shows both worksheets.
  final Grade? grade;

  const AnswerKey({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final grades = grade == null ? Grade.values : [grade!];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 1000 ? 2 : 1;
        final width = (c.maxWidth - (cols - 1) * 16) / cols;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final g in grades) ...[
              PillTitle(
                text: Words.gradeCity.tr(args: ['${g.number}']),
                color: g.color,
                leading: Emoji(g.emoji, size: 18),
              ),
              14.height,
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final p in Problem.ofGrade(g))
                    SizedBox(width: width, child: _KeyCard(problem: p)),
                ],
              ),
              24.height,
            ],
          ],
        );
      },
    );
  }
}

class _KeyCard extends StatelessWidget {
  final Problem problem;

  const _KeyCard({required this.problem});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tint: problem.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: PillTitle(
                  text: '${problem.number}. ${problem.place}',
                  color: problem.color,
                  leading: Emoji(problem.emoji, size: 18),
                ),
              ),
              10.width,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: theme.green, borderRadius: 16.circular),
                child: Text(
                  Words.answerLabel.tr(args: ['${problem.total}']),
                  style: theme.display(20, color: theme.white),
                ),
              ),
            ],
          ),
          12.height,
          Text(problem.statement, style: theme.body(15, color: theme.textMuted)),
          10.height,
          Text(problem.formula, style: theme.display(26, color: problem.color)),
          4.height,
          Text(problem.explanation, style: theme.body(15)),
          12.height,
          Align(
            alignment: Alignment.centerRight,
            child: ClayButton(
              color: problem.color,
              depth: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => context.go(Routes.problemOf(problem.id)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded),
                  6.width,
                  Text(Words.openProblem.tr(), style: theme.display(17, color: theme.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
