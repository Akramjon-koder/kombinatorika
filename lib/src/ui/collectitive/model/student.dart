import 'package:equatable/equatable.dart';

/// Best result of one learner on one problem.
final class ProblemResult extends Equatable {
  /// 0…3 stars (answer right + all variants found + no mistakes).
  final int stars;

  /// How many times "Tekshirish" was pressed.
  final int attempts;

  /// Whether the numeric answer was correct at least once.
  final bool solved;

  /// Most variants found in one go.
  final int found;

  const ProblemResult({
    this.stars = 0,
    this.attempts = 0,
    this.solved = false,
    this.found = 0,
  });

  factory ProblemResult.fromJson(Map<String, dynamic> json) => ProblemResult(
        stars: json['stars'] as int? ?? 0,
        attempts: json['attempts'] as int? ?? 0,
        solved: json['solved'] as bool? ?? false,
        found: json['found'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'stars': stars,
        'attempts': attempts,
        'solved': solved,
        'found': found,
      };

  /// Keeps the best of both results, summing attempts.
  ProblemResult merge(ProblemResult other) => ProblemResult(
        stars: other.stars > stars ? other.stars : stars,
        attempts: attempts + other.attempts,
        solved: solved || other.solved,
        found: other.found > found ? other.found : found,
      );

  @override
  List<Object?> get props => [stars, attempts, solved, found];
}

/// A learner who played on this device.
final class Student extends Equatable {
  final String name;

  /// Avatar emoji picked on the welcome screen.
  final String avatar;

  /// Results by problem id.
  final Map<int, ProblemResult> results;

  const Student({
    required this.name,
    required this.avatar,
    this.results = const {},
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] as String? ?? '🧒',
        results: {
          for (final e
              in (json['results'] as Map<String, dynamic>? ?? {}).entries)
            int.parse(e.key):
                ProblemResult.fromJson(e.value as Map<String, dynamic>),
        },
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'results': {
          for (final e in results.entries) '${e.key}': e.value.toJson(),
        },
      };

  /// Total stars over all problems.
  int get stars => results.values.fold(0, (s, r) => s + r.stars);

  /// Number of solved problems.
  int get solvedCount => results.values.where((r) => r.solved).length;

  Student copyWith({String? avatar, Map<int, ProblemResult>? results}) =>
      Student(
        name: name,
        avatar: avatar ?? this.avatar,
        results: results ?? this.results,
      );

  @override
  List<Object?> get props => [name, avatar, results];
}
