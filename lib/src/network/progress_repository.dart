import 'package:flutter/foundation.dart';

import '../helpers/shared_service.dart';
import '../ui/collectitive/model/student.dart';

/// Local (device) storage of learners and their results. There is no backend:
/// the teacher sees every learner who played on the same computer.
///
/// [current] is reactive — the router's `refreshListenable` and header chips
/// listen to it, so signing in/out re-routes and re-renders automatically.
class ProgressRepository {
  final SharedPrefService _pref;

  /// Signed-in learner, `null` on the welcome screen / teacher area.
  final ValueNotifier<Student?> current = ValueNotifier(null);

  /// Every learner on this device (teacher dashboard).
  final ValueNotifier<List<Student>> students = ValueNotifier([]);

  ProgressRepository(this._pref) {
    students.value = _pref.getStudents();
    final name = _pref.getCurrentStudent();
    current.value = _find(name);
  }

  Student? _find(String? name) {
    if (name == null) return null;
    for (final s in students.value) {
      if (s.name.toLowerCase() == name.toLowerCase()) return s;
    }
    return null;
  }

  /// Signs a learner in, creating them on first visit.
  Future<void> signIn(String name, String avatar) async {
    final trimmed = name.trim();
    var student = _find(trimmed);
    if (student == null) {
      student = Student(name: trimmed, avatar: avatar);
      students.value = [...students.value, student];
    } else if (student.avatar != avatar) {
      student = student.copyWith(avatar: avatar);
      _replace(student);
    }
    await _pref.setStudents(students.value);
    await _pref.setCurrentStudent(student.name);
    current.value = student;
  }

  Future<void> signOut() async {
    await _pref.setCurrentStudent(null);
    current.value = null;
  }

  /// Merges [result] into the current learner's best result for [problemId].
  Future<void> saveResult(int problemId, ProblemResult result) async {
    final student = current.value;
    if (student == null) return;
    final old = student.results[problemId] ?? const ProblemResult();
    final updated = student.copyWith(
      results: {...student.results, problemId: old.merge(result)},
    );
    _replace(updated);
    current.value = updated;
    await _pref.setStudents(students.value);
  }

  /// Removes a learner (teacher dashboard).
  Future<void> deleteStudent(String name) async {
    students.value = students.value.where((s) => s.name != name).toList();
    await _pref.setStudents(students.value);
    if (current.value?.name == name) await signOut();
  }

  void _replace(Student student) {
    students.value = [
      for (final s in students.value) s.name == student.name ? student : s,
    ];
  }
}
