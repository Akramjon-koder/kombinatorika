import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../network/progress_repository.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/model/grade.dart';
import '../../../collectitive/model/student.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../../collectitive/widgets/student_chip.dart';
import '../../../problems/model/problem.dart';
import '../dialogs/confirm_delete_dialog.dart';
import '../teacher_screen.dart';

/// Learners × problems grid: stars per problem (✓ solved), attempts as a
/// tooltip, and total stars. Sorted by total stars. Column N is problem N of
/// each learner's own grade, so learners of both grades fit one table.
class ResultsTable extends StatelessWidget {
  /// Shown grade; `null` lists every learner with a grade column.
  final Grade? grade;

  const ResultsTable({super.key, required this.grade});

  /// Number of problems in one worksheet (columns 1…N).
  static int get _columns => Problem.ofGrade(Grade.fourth).length;

  Future<void> onTapDelete(BuildContext context, Student s) async {
    final repo = context.read<ProgressRepository>();
    final ok = await showConfirmDeleteDialog(context, s.name);
    if (ok == true) await repo.deleteStudent(s);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProgressRepository>();
    final heads = grade == null ? null : Problem.ofGrade(grade!);
    return ValueListenableBuilder<List<Student>>(
      valueListenable: repo.students,
      builder: (context, students, _) {
        if (students.isEmpty) return const TeacherEmpty();
        final shown = students.where((s) => grade == null || s.grade == grade).toList();
        if (shown.isEmpty) return const TeacherEmpty(text: Words.teacherGradeEmpty);
        final sorted = shown..sort((a, b) => b.stars.compareTo(a.stars));
        return GlassCard(
          tint: theme.violet,
          padding: 16.all,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 58,
              dataRowMaxHeight: 64,
              columnSpacing: 14,
              headingTextStyle: theme.display(17, color: theme.violet),
              columns: [
                DataColumn(label: Text(Words.teacherStudent.tr())),
                if (grade == null) DataColumn(label: Text(Words.teacherGrade.tr())),
                for (var n = 1; n <= _columns; n++)
                  DataColumn(
                    label: Tooltip(
                      message: heads == null ? Words.problemN.tr(args: ['$n']) : heads[n - 1].place,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (heads != null) Emoji(heads[n - 1].emoji, size: 18),
                          Text('$n'),
                        ],
                      ),
                    ),
                  ),
                DataColumn(label: Text(Words.teacherTotal.tr())),
                const DataColumn(label: SizedBox.shrink()),
              ],
              rows: [
                for (final s in sorted)
                  DataRow(
                    cells: [
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Emoji(s.avatar, size: 26),
                          8.width,
                          Text(s.name, style: theme.display(18)),
                        ],
                      )),
                      if (grade == null)
                        DataCell(Text(
                          Words.gradeN.tr(args: ['${s.grade.number}']),
                          style: theme.display(17, color: s.grade.color),
                        )),
                      for (final p in Problem.ofGrade(s.grade)) DataCell(_ResultCell(result: s.results[p.id])),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Emoji('⭐', size: 18),
                          4.width,
                          Text('${s.stars}', style: theme.display(20, color: theme.secondary)),
                          Text(
                            ' · ${s.solvedCount}/${Problem.ofGrade(s.grade).length}',
                            style: theme.body(14, color: theme.textMuted),
                          ),
                        ],
                      )),
                      DataCell(IconButton(
                        tooltip: Words.teacherDelete.tr(),
                        icon: Icon(Icons.delete_outline_rounded, color: theme.error),
                        onPressed: () => onTapDelete(context, s),
                      )),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultCell extends StatelessWidget {
  final ProblemResult? result;

  const _ResultCell({required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) return Text('—', style: theme.body(16, color: theme.textHint));
    return Tooltip(
      message: 'Urinishlar: ${r.attempts}, topilgan variantlar: ${r.found}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            r.solved ? Icons.check_circle_rounded : Icons.timelapse_rounded,
            size: 20,
            color: r.solved ? theme.green : theme.amber,
          ),
          StarRow(stars: r.stars, size: 13),
        ],
      ),
    );
  }
}
