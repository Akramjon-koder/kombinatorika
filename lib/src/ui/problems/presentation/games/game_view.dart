import 'package:flutter/material.dart';

import '../../model/problem.dart';
import 'breakfast_game.dart';
import 'buses_game.dart';
import 'canteen_game.dart';
import 'carpets_game.dart';
import 'cups_game.dart';
import 'dancers_game.dart';
import 'houses_game.dart';
import 'insect_cards_game.dart';
import 'picnic_game.dart';
import 'routes_game.dart';

/// Picks the individual mini-game of [problem]. Games read/write the
/// surrounding `ProblemBloc` (variants) and keep only their local UI state.
class GameView extends StatelessWidget {
  final Problem problem;

  const GameView({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return switch (problem.kind) {
      ProblemKind.canteen => CanteenGame(problem: problem),
      ProblemKind.insectCards => InsectCardsGame(problem: problem),
      ProblemKind.carpets => CarpetsGame(problem: problem),
      ProblemKind.breakfast => BreakfastGame(problem: problem),
      ProblemKind.houses => HousesGame(problem: problem),
      ProblemKind.dancers => DancersGame(problem: problem),
      ProblemKind.buses => BusesGame(problem: problem),
      ProblemKind.routes => RoutesGame(problem: problem),
      ProblemKind.picnic => PicnicGame(problem: problem),
      ProblemKind.cups => CupsGame(problem: problem),
    };
  }
}
