import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/routes.dart';
import '../../../constants/string.dart';
import '../../../extensions/size_extensions.dart';
import '../../../theme/apptheme.dart';
import '../../collectitive/model/grade.dart';
import '../../collectitive/widgets/clay_button.dart';
import '../../collectitive/widgets/glass_card.dart';
import '../../collectitive/widgets/scene_background.dart';
import '../../collectitive/widgets/wood_plaque.dart';
import 'parts/answer_key.dart';
import 'parts/results_table.dart';

/// Teacher room: results of every learner who played on this device and the
/// answer key with explanations (each problem can be tried from here). Both
/// tabs are filtered by the selected grade.
class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _tab = 0;

  /// Grade filter of both tabs; `null` shows every grade.
  Grade? _grade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SceneBackground(
        tint: theme.violet,
        houses: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: 20.top,
                          child: ClayButton(
                            color: theme.primary,
                            onTap: () => context.go(Routes.welcome),
                            radius: 20,
                            depth: 4,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_back_rounded),
                                8.width,
                                Text(Words.back.tr(), style: theme.display(18, color: theme.white)),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: WoodPlaque(
                              title: Words.teacherTitle.tr(),
                              emoji: '🧑‍🏫',
                              color: theme.violet,
                              compact: MediaQuery.sizeOf(context).width < 900,
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.sizeOf(context).width < 900 ? 0 : 120),
                      ],
                    ),
                    16.height,
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _TabButton(
                          text: Words.teacherResults.tr(),
                          icon: Icons.leaderboard_rounded,
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                        _TabButton(
                          text: Words.teacherKey.tr(),
                          icon: Icons.menu_book_rounded,
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ],
                    ),
                    12.height,
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final g in <Grade?>[null, ...Grade.values])
                          _TabButton(
                            text: g == null ? Words.teacherAllGrades.tr() : Words.gradeN.tr(args: ['${g.number}']),
                            icon: g == null ? Icons.groups_rounded : Icons.school_rounded,
                            color: g?.color ?? theme.primary,
                            small: true,
                            selected: _grade == g,
                            onTap: () => setState(() => _grade = g),
                          ),
                      ],
                    ),
                    18.height,
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _tab == 0
                          ? ResultsTable(key: ValueKey('results$_grade'), grade: _grade)
                          : AnswerKey(key: ValueKey('key$_grade'), grade: _grade),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle button of the tab bar and of the grade filter.
class _TabButton extends StatelessWidget {
  /// Caption.
  final String text;

  /// Leading icon.
  final IconData icon;

  /// Whether this tab / filter is active.
  final bool selected;

  /// Activates the tab / filter.
  final VoidCallback onTap;

  /// Colour when selected (grey otherwise).
  final Color? color;

  /// Smaller variant used by the grade filter.
  final bool small;

  const _TabButton({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClayButton(
      color: selected ? color ?? theme.violet : theme.textHint,
      onTap: onTap,
      depth: selected ? (small ? 4 : 6) : 3,
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 20 : null),
          8.width,
          Text(text, style: theme.display(small ? 17 : 19, color: theme.white)),
        ],
      ),
    );
  }
}

/// Re-exported for parts: an empty-state card.
class TeacherEmpty extends StatelessWidget {
  /// Translation key of the message.
  final String text;

  const TeacherEmpty({super.key, this.text = Words.teacherEmpty});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 30.all,
      child: Column(
        children: [
          const Emoji('📭', size: 60),
          10.height,
          Text(
            text.tr(),
            textAlign: TextAlign.center,
            style: theme.body(17, color: theme.textMuted),
          ),
        ],
      ),
    );
  }
}
