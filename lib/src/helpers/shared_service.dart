import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../ui/collectitive/model/student.dart';

/// Thin typed wrapper over [SharedPreferences]. Only [ProgressRepository]
/// writes through it, so the repository's notifiers stay the source of truth.
class SharedPrefService {
  static const String _students = 'students';
  static const String _currentStudent = 'current_student';
  static late SharedPreferences _preference;

  const SharedPrefService._();

  static Future<SharedPrefService> initialize() async {
    _preference = await SharedPreferences.getInstance();
    return const SharedPrefService._();
  }

  ///Students (all learners who played on this device)
  List<Student> getStudents() {
    final raw = _preference.getString(_students);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> setStudents(List<Student> students) async =>
      await _preference.setString(
        _students,
        jsonEncode(students.map((e) => e.toJson()).toList()),
      );

  ///Current learner name
  String? getCurrentStudent() => _preference.getString(_currentStudent);

  Future<bool> setCurrentStudent(String? name) async => name == null
      ? await _preference.remove(_currentStudent)
      : await _preference.setString(_currentStudent, name);
}
