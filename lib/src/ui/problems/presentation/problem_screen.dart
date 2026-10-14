import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/routes.dart';
import '../../../constants/string.dart';
import '../../../extensions/size_extensions.dart';
import '../../../network/progress_repository.dart';
import '../../../theme/apptheme.dart';
import '../../collectitive/widgets/clay_button.dart';
import '../../collectitive/widgets/confetti.dart';
import '../../collectitive/widgets/glass_card.dart';
import '../../collectitive/widgets/scene_background.dart';
import '../../collectitive/widgets/speech_bubble.dart';
import '../../collectitive/widgets/student_chip.dart';
import '../../collectitive/widgets/wood_plaque.dart';
import '../bloc/bloc.dart';
import '../model/problem.dart';
import 'dialogs/solved_dialog.dart';
import 'games/game_view.dart';
import 'parts/problem_nav.dart';
import 'parts/side_panel.dart';
import 'parts/toast.dart';

/// One problem of the worksheet (see `resources/13.jpg`, `14.jpg`): plaque,
/// statement, the problem's own mini-game, and the variants / answer panel.
/// Owns its [ProblemBloc].
class ProblemScreen extends StatelessWidget {
  final Problem problem;

  const ProblemScreen({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProblemBloc(context.read<ProgressRepository>(), problem),
      child: _ProblemView(problem: problem),
    );
  }
}

class _ProblemView extends StatelessWidget {
  final Problem problem;

  const _ProblemView({required this.problem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SceneBackground(
        tint: problem.color,
        houses: false,
        child: SafeArea(
          child: BlocListener<ProblemBloc, ProblemState>(
            listenWhen: (p, c) => p.stars != c.stars && c.isSolved,
            listener: (context, state) => showSolvedDialog(context, problem, state.stars),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth > 1100;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1500),
                          child: Column(
                            children: [
                              _TopBar(problem: problem, wide: wide),
                              14.height,
                              wide ? _WideBody(problem: problem) : _NarrowBody(problem: problem),
                              18.height,
                              ProblemNav(problem: problem),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: BlocSelector<ProblemBloc, ProblemState, int>(
                    selector: (s) => s.isSolved ? s.stars : 0,
                    builder: (context, stars) => Confetti(trigger: stars == 0 ? null : stars),
                  ),
                ),
                const Positioned(top: 130, left: 16, right: 16, child: ProblemToast()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Problem problem;
  final bool wide;

  const _TopBar({required this.problem, required this.wide});

  @override
  Widget build(BuildContext context) {
    final back = ClayButton(
      color: theme.primary,
      onTap: () => context.go(
        context.read<ProgressRepository>().current.value == null ? Routes.teacher : Routes.city,
      ),
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
    );
    final plaque = WoodPlaque(
      title: problem.place,
      emoji: problem.emoji,
      color: problem.color,
      compact: !wide,
    );
    if (!wide) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [back, 10.width, const Flexible(child: StudentChip())],
          ),
          10.height,
          plaque,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(padding: 20.top, child: back),
          ),
        ),
        plaque,
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(padding: 20.top, child: const StudentChip()),
          ),
        ),
      ],
    );
  }
}

/// Mascot | problem card | side panel.
class _WideBody extends StatelessWidget {
  final Problem problem;

  const _WideBody({required this.problem});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (MediaQuery.sizeOf(context).width > 1380)
          SizedBox(
            width: 210,
            child: Padding(
              padding: 120.top,
              child: Mascot(
                emoji: problem.id.isEven ? '🧒🏻' : '👧🏻',
                text: problem.tip,
                size: 120,
              ),
            ),
          ),
        Expanded(child: _ProblemCard(problem: problem)),
        18.width,
        SizedBox(width: 340, child: SidePanel(problem: problem)),
      ],
    );
  }
}

class _NarrowBody extends StatelessWidget {
  final Problem problem;

  const _NarrowBody({required this.problem});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProblemCard(problem: problem),
        16.height,
        SidePanel(problem: problem),
      ],
    );
  }
}

/// Statement + the mini-game.
class _ProblemCard extends StatelessWidget {
  final Problem problem;

  const _ProblemCard({required this.problem});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width <= 1380;
    return GlassCard(
      tint: problem.color,
      padding: 22.all,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillTitle(
            text: Words.problemN.tr(args: ['${problem.number}']),
            color: problem.color,
            leading: Text('${problem.number}', style: theme.display(18, color: problem.color)),
          ),
          14.height,
          Text(problem.statement, style: theme.body(19, color: theme.text)),
          if (narrow) ...[
            10.height,
            Row(
              children: [
                const Emoji('💡', size: 22),
                8.width,
                Expanded(
                  child: Text(problem.tip, style: theme.body(15, color: problem.color)),
                ),
              ],
            ),
          ],
          18.height,
          BlocSelector<ProblemBloc, ProblemState, int>(
            selector: (s) => s.round,
            builder: (context, round) => GameView(key: ValueKey(round), problem: problem),
          ),
        ],
      ),
    );
  }
}
