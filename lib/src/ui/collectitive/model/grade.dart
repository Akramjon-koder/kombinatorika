import 'package:flutter/material.dart';

import '../../../theme/apptheme.dart';

/// School grade of a learner. Each grade has its own city and its own
/// worksheet: 3rd grade — `resources/masalalar tajriba.docx`,
/// 4th grade — `resources/masala tajriba 2.docx`.
enum Grade {
  /// 3rd grade.
  third(3, '🎈'),

  /// 4th grade.
  fourth(4, '🚀');

  /// Grade number shown to the user and stored in JSON.
  final int number;

  /// Decoration emoji of the grade's city.
  final String emoji;

  const Grade(this.number, this.emoji);

  /// Accent colour of the grade (picker cards, teacher filter, badges).
  Color get color => switch (this) {
        Grade.third => theme.secondary,
        Grade.fourth => theme.pink,
      };

  /// Parses a stored grade number; legacy data (no grade) played the
  /// `masalalar tajriba.docx` worksheet, i.e. the 3rd grade.
  static Grade fromNumber(int? number) =>
      Grade.values.firstWhere((g) => g.number == number, orElse: () => Grade.third);
}
