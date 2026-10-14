import 'package:flutter/material.dart';

import '../../model/problem.dart';
import 'balloons_game.dart';
import 'banknotes_game.dart';
import 'breakfast_game.dart';
import 'buses_game.dart';
import 'canteen_game.dart';
import 'carpets_game.dart';
import 'chess_game.dart';
import 'cups_game.dart';
import 'dancers_game.dart';
import 'digit_cards_game.dart';
import 'flower_pots_game.dart';
import 'houses_game.dart';
import 'ice_cream_game.dart';
import 'insect_cards_game.dart';
import 'parrots_game.dart';
import 'picnic_game.dart';
import 'routes_game.dart';
import 'school_shop_game.dart';
import 'snack_bar_game.dart';
import 'trails_game.dart';

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
      ProblemKind.trails => TrailsGame(problem: problem),
      ProblemKind.flowerPots => FlowerPotsGame(problem: problem),
      ProblemKind.snackBar => SnackBarGame(problem: problem),
      ProblemKind.balloons => BalloonsGame(problem: problem),
      ProblemKind.banknotes => BanknotesGame(problem: problem),
      ProblemKind.digitCards => DigitCardsGame(problem: problem),
      ProblemKind.chess => ChessGame(problem: problem),
      ProblemKind.parrots => ParrotsGame(problem: problem),
      ProblemKind.iceCream => IceCreamGame(problem: problem),
      ProblemKind.schoolShop => SchoolShopGame(problem: problem),
    };
  }
}
