import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/routes.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../network/progress_repository.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/model/student.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../model/problem.dart';

/// "‹ ● ● ○ ○ ›" pager between the problems of one grade; solved dots are green.
class ProblemNav extends StatelessWidget {
  final Problem problem;

  const ProblemNav({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    final all = Problem.ofGrade(problem.grade);
    final repo = context.read<ProgressRepository>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.glass,
        borderRadius: 40.circular,
        boxShadow: theme.lifted(theme.primary, depth: 0.4),
      ),
      child: ValueListenableBuilder<Student?>(
        valueListenable: repo.current,
        builder: (context, student, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClayIconButton(
              icon: Icons.chevron_left_rounded,
              onTap: problem.previous == null
                  ? null
                  : () => context.go(Routes.problemOf(problem.previous!.id)),
            ),
            12.width,
            for (final p in all)
              GestureDetector(
                onTap: () => context.go(Routes.problemOf(p.id)),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: 3.horizontal,
                    width: p.id == problem.id ? 28 : 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: p.id == problem.id
                          ? problem.color
                          : (student?.results[p.id]?.solved ?? false)
                              ? theme.green
                              : theme.slotBorder,
                      borderRadius: 10.circular,
                    ),
                  ),
                ),
              ),
            12.width,
            ClayIconButton(
              icon: Icons.chevron_right_rounded,
              onTap: problem.next == null
                  ? null
                  : () => context.go(Routes.problemOf(problem.next!.id)),
            ),
          ],
        ),
      ),
    );
  }
}
