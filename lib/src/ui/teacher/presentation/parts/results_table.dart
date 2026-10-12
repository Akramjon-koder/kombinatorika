import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../network/progress_repository.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/model/student.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../../collectitive/widgets/student_chip.dart';
import '../../../problems/model/problem.dart';
import '../dialogs/confirm_delete_dialog.dart';
import '../teacher_screen.dart';

/// Learners × problems grid: stars per problem (✓ solved), attempts as a
/// tooltip, and total stars. Sorted by total stars.
class ResultsTable extends StatelessWidget {
  const ResultsTable({super.key});

  Future<void> onTapDelete(BuildContext context, Student s) async {
    final repo = context.read<ProgressRepository>();
    final ok = await showConfirmDeleteDialog(context, s.name);
    if (ok == true) await repo.deleteStudent(s.name);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProgressRepository>();
    return ValueListenableBuilder<List<Student>>(
      valueListenable: repo.students,
      builder: (context, students, _) {
        if (students.isEmpty) return const TeacherEmpty();
        final sorted = [...students]..sort((a, b) => b.stars.compareTo(a.stars));
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
                for (final p in Problem.all)
                  DataColumn(
                    label: Tooltip(
                      message: p.place,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Emoji(p.emoji, size: 18), Text('${p.id}')],
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
                      for (final p in Problem.all) DataCell(_ResultCell(result: s.results[p.id])),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Emoji('⭐', size: 18),
                          4.width,
                          Text('${s.stars}', style: theme.display(20, color: theme.secondary)),
                          Text(' · ${s.solvedCount}/${Problem.all.length}', style: theme.body(14, color: theme.textMuted)),
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
