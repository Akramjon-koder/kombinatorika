import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/routes.dart';
import '../../../constants/string.dart';
import '../../../extensions/size_extensions.dart';
import '../../../network/progress_repository.dart';
import '../../../theme/apptheme.dart';
import '../../collectitive/model/student.dart';
import '../../collectitive/widgets/brand_logo.dart';
import '../../collectitive/widgets/clay_button.dart';
import '../../collectitive/widgets/glass_card.dart';
import '../../collectitive/widgets/scene_background.dart';
import '../../collectitive/widgets/student_chip.dart';
import '../../problems/model/problem.dart';
import 'dialogs/how_to_play_dialog.dart';
import 'widgets/island_map.dart';
import 'widgets/paper_island.dart';

/// City map (see `resources/12.jpg` + the wooden-map idea of `examplee.jpg`):
/// every worksheet problem is a paper-cut island on a treasure map, linked by
/// a dashed trail in worksheet order.
class CityScreen extends StatelessWidget {
  const CityScreen({super.key});

  Future<void> onTapSignOut(BuildContext context) async {
    await context.read<ProgressRepository>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProgressRepository>();
    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: ValueListenableBuilder<Student?>(
            valueListenable: repo.current,
            builder: (context, student, _) {
              final results = student?.results ?? const {};
              return LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth > 980;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Column(
                          children: [
                            _Header(
                              wide: wide,
                              onTapHow: () => showHowToPlayDialog(context),
                              onTapSignOut: () => onTapSignOut(context),
                            ),
                            18.height,
                            _Greeting(student: student),
                            18.height,
                            if (wide)
                              IslandMap(
                                results: results,
                                onTap: (p) => context.go(Routes.problemOf(p.id)),
                              )
                            else
                              Wrap(
                                spacing: 18,
                                runSpacing: 22,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (final p in Problem.all)
                                    SizedBox(
                                      width: 170,
                                      height: 200,
                                      child: PaperIsland(
                                        problem: p,
                                        result: results[p.id],
                                        onTap: () => context.go(Routes.problemOf(p.id)),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool wide;
  final VoidCallback onTapHow;
  final VoidCallback onTapSignOut;

  const _Header({required this.wide, required this.onTapHow, required this.onTapSignOut});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      spacing: 12,
      children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Emoji('🧠', size: 40),
              12.width,
              BrandLogo(scale: wide ? 0.42 : 0.34, slogan: false),
              if (wide) ...[
                20.width,
                Text(
                  Words.brandSlogan.tr(),
                  style: theme.body(15, color: theme.primary, weight: FontWeight.w800),
                ),
              ],
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StudentChip(),
            12.width,
            ClayIconButton(
              icon: Icons.lightbulb_rounded,
              color: theme.secondary,
              tooltip: Words.cityHow.tr(),
              onTap: onTapHow,
            ),
            10.width,
            ClayIconButton(
              icon: Icons.logout_rounded,
              color: theme.pink,
              tooltip: Words.signOut.tr(),
              onTap: onTapSignOut,
            ),
          ],
        ),
      ],
    );
  }
}

/// "Salom, Madina!" + overall progress bar.
class _Greeting extends StatelessWidget {
  final Student? student;

  const _Greeting({required this.student});

  @override
  Widget build(BuildContext context) {
    final solved = student?.solvedCount ?? 0;
    final total = Problem.all.length;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 10,
        children: [
          Text(
            Words.cityHello.tr(args: [student?.name ?? '']),
            style: theme.display(28),
          ),
          SizedBox(
            width: 280,
            child: ClipRRect(
              borderRadius: 20.circular,
              child: LinearProgressIndicator(
                value: solved / total,
                minHeight: 16,
                color: theme.green,
                backgroundColor: theme.surfaceSubtle,
              ),
            ),
          ),
          Text(
            Words.cityProgress.tr(args: ['$solved', '$total']),
            style: theme.body(16, color: theme.textMuted),
          ),
        ],
      ),
    );
  }
}
