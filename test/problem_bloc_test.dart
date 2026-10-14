import 'package:flutter_test/flutter_test.dart';
import 'package:kombinatorika/src/helpers/shared_service.dart';
import 'package:kombinatorika/src/network/progress_repository.dart';
import 'package:kombinatorika/src/ui/collectitive/model/grade.dart';
import 'package:kombinatorika/src/ui/collectitive/model/student.dart';
import 'package:kombinatorika/src/ui/problems/bloc/bloc.dart';
import 'package:kombinatorika/src/ui/problems/model/problem.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProgressRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = ProgressRepository(await SharedPrefService.initialize());
    await repo.signIn('Test', '🐼', Grade.third);
  });

  test('every problem answer matches its formula', () {
    final totals = {for (final p in Problem.all) p.id: p.total};
    expect(totals, {
      // 3rd grade — masalalar tajriba.docx
      1: 9, 2: 6, 3: 3, 4: 9, 5: 6, 6: 4, 7: 6, 8: 6, 9: 4, 10: 6,
      // 4th grade — masala tajriba 2.docx
      11: 6, 12: 3, 13: 12, 14: 10, 15: 10, 16: 24, 17: 10, 18: 6, 19: 12, 20: 5,
    });
  });

  test('each grade has its own 10 problems numbered 1…10', () {
    for (final g in Grade.values) {
      final list = Problem.ofGrade(g);
      expect(list.map((p) => p.number), [for (var n = 1; n <= 10; n++) n]);
      expect(list.first.previous, isNull);
      expect(list.last.next, isNull);
      expect(list.first.next, list[1]);
    }
  });

  test('the same name in two grades is two learners; legacy data is 3rd grade', () async {
    await repo.signIn('test', '🦊', Grade.fourth);
    expect(repo.students.value.length, 2);
    expect(repo.current.value!.grade, Grade.fourth);
    expect(Student.fromJson({'name': 'Old'}).grade, Grade.third);
    await repo.deleteStudent(repo.current.value!);
    expect(repo.current.value, isNull);
    expect(repo.students.value.single.grade, Grade.third);
  });

  test('duplicates are rejected, full solve gives 3 stars and is saved', () async {
    final problem = Problem.byId(9)!;
    final bloc = ProblemBloc(repo, problem);
    for (final k in ['OG', 'OK', 'AG', 'OG', 'AK']) {
      bloc.add(ProblemVariantAdded(Variant(key: k, label: k)));
    }
    bloc.add(const ProblemAnswerChanged('4'));
    bloc.add(const ProblemChecked());
    final solved = await bloc.stream.firstWhere((s) => s.isSolved);
    expect(solved.found.length, 4);
    expect(solved.stars, 3);
    expect(repo.current.value!.results[9]!.solved, isTrue);
    await bloc.close();
  });

  test('a wrong answer costs the "no mistakes" star', () async {
    final bloc = ProblemBloc(repo, Problem.byId(3)!);
    bloc.add(const ProblemAnswerChanged('6'));
    bloc.add(const ProblemChecked());
    bloc.add(const ProblemAnswerChanged('3'));
    bloc.add(const ProblemChecked());
    final solved = await bloc.stream.firstWhere((s) => s.isSolved);
    expect(solved.stars, 1); // right answer, variants not shown, 1 mistake
    await bloc.close();
  });
}
