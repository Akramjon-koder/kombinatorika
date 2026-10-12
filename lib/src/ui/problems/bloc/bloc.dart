import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/string.dart';
import '../../../network/progress_repository.dart';
import '../../collectitive/model/student.dart';
import '../model/problem.dart';

part 'event.dart';
part 'state.dart';

/// Drives one problem: collects the variants the mini-game produces, rejects
/// duplicates, checks the numeric answer and stores the learner's result.
class ProblemBloc extends Bloc<ProblemEvent, ProblemState> {
  final ProgressRepository _repository;
  final Problem problem;
  int _seq = 0;

  ProblemBloc(this._repository, this.problem) : super(ProblemState.initial()) {
    on<ProblemVariantAdded>(_onAdded);
    on<ProblemVariantRemoved>(_onRemoved);
    on<ProblemVariantsSynced>(_onSynced);
    on<ProblemHintShown>(_onHint);
    on<ProblemAnswerChanged>(_onAnswer);
    on<ProblemChecked>(_onChecked);
    on<ProblemReset>(_onReset);
  }

  ProblemMessage _msg(String text, MessageTone tone, {bool translate = true}) =>
      ProblemMessage(text, tone, ++_seq, translate: translate);

  void _onAdded(ProblemVariantAdded event, Emitter<ProblemState> emit) {
    final v = event.variant;
    if (state.found.contains(v)) {
      emit(state.copyWith(
        highlight: v.key,
        message: _msg(Words.msgDuplicate, MessageTone.warning),
      ));
      return;
    }
    final found = [...state.found, v];
    emit(state.copyWith(
      found: found,
      highlight: v.key,
      message: found.length == problem.total
          ? _msg(Words.msgAllFound, MessageTone.success)
          : _msg(Words.msgNew, MessageTone.success),
    ));
  }

  void _onRemoved(ProblemVariantRemoved event, Emitter<ProblemState> emit) {
    emit(state.copyWith(
      found: state.found.where((v) => v.key != event.key).toList(),
    ));
  }

  void _onSynced(ProblemVariantsSynced event, Emitter<ProblemState> emit) {
    final before = state.found.map((v) => v.key).toSet();
    final added = event.variants.where((v) => !before.contains(v.key));
    final allFound = event.variants.length == problem.total &&
        state.found.length != problem.total;
    emit(state.copyWith(
      found: event.variants,
      highlight: added.isEmpty ? null : added.last.key,
      message: allFound
          ? _msg(Words.msgAllFound, MessageTone.success)
          : added.isNotEmpty
              ? _msg(Words.msgNew, MessageTone.success)
              : null,
    ));
  }

  void _onHint(ProblemHintShown event, Emitter<ProblemState> emit) {
    emit(state.copyWith(
      message: _msg(event.text, event.tone, translate: false),
    ));
  }

  void _onAnswer(ProblemAnswerChanged event, Emitter<ProblemState> emit) {
    emit(state.copyWith(answer: event.answer));
  }

  Future<void> _onChecked(
    ProblemChecked event,
    Emitter<ProblemState> emit,
  ) async {
    final answer = int.tryParse(state.answer.trim());
    if (answer == null) {
      emit(state.copyWith(message: _msg(Words.msgEnterAnswer, MessageTone.info)));
      return;
    }
    final attempts = state.attempts + 1;
    if (answer != problem.total) {
      emit(state.copyWith(
        attempts: attempts,
        mistakes: state.mistakes + 1,
        message: _msg(Words.msgWrong, MessageTone.error),
      ));
      await _repository.saveResult(
        problem.id,
        ProblemResult(attempts: 1, found: state.found.length),
      );
      return;
    }
    final allFound = state.found.length >= problem.total;
    final stars = 1 + (allFound ? 1 : 0) + (state.mistakes == 0 ? 1 : 0);
    emit(state.copyWith(
      status: ProblemStatus.solved,
      attempts: attempts,
      stars: stars,
      message: allFound ? null : _msg(Words.msgRightMissing, MessageTone.info),
    ));
    await _repository.saveResult(
      problem.id,
      ProblemResult(
        stars: stars,
        attempts: 1,
        solved: true,
        found: state.found.length,
      ),
    );
  }

  void _onReset(ProblemReset event, Emitter<ProblemState> emit) {
    emit(ProblemState.initial().copyWith(round: state.round + 1));
  }
}
