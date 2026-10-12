part of 'bloc.dart';

enum ProblemStatus { playing, solved }

enum MessageTone { info, success, warning, error }

/// Transient toast shown by the problem screen. Every message gets a fresh
/// [seq] so the same text twice in a row is still shown twice.
final class ProblemMessage extends Equatable {
  final String text;
  final MessageTone tone;

  /// True when [text] is a `Words` key that must be translated.
  final bool translate;
  final int seq;

  const ProblemMessage(this.text, this.tone, this.seq, {this.translate = true});

  @override
  List<Object?> get props => [text, tone, translate, seq];
}

final class ProblemState extends Equatable {
  final ProblemStatus status;
  final List<Variant> found;
  final String answer;
  final int attempts;
  final int mistakes;

  /// Key of the variant to flash in the side panel (new or duplicate).
  final String? highlight;

  /// Bumped by [ProblemReset]; the screen re-keys the game with it.
  final int round;

  /// Stars earned by the solving check (0 while playing).
  final int stars;

  /// Toast payload. Cleared on every emit (copyWith replaces, never `?? this`).
  final ProblemMessage? message;

  const ProblemState({
    required this.status,
    required this.found,
    required this.answer,
    required this.attempts,
    required this.mistakes,
    required this.round,
    required this.stars,
    this.highlight,
    this.message,
  });

  factory ProblemState.initial() => const ProblemState(
        status: ProblemStatus.playing,
        found: [],
        answer: '',
        attempts: 0,
        mistakes: 0,
        round: 0,
        stars: 0,
      );

  bool get isSolved => status == ProblemStatus.solved;

  ProblemState copyWith({
    ProblemStatus? status,
    List<Variant>? found,
    String? answer,
    int? attempts,
    int? mistakes,
    int? round,
    int? stars,
    String? highlight,
    ProblemMessage? message,
  }) =>
      ProblemState(
        status: status ?? this.status,
        found: found ?? this.found,
        answer: answer ?? this.answer,
        attempts: attempts ?? this.attempts,
        mistakes: mistakes ?? this.mistakes,
        round: round ?? this.round,
        stars: stars ?? this.stars,
        highlight: highlight,
        message: message,
      );

  @override
  List<Object?> get props => [
        status,
        found,
        answer,
        attempts,
        mistakes,
        round,
        stars,
        highlight,
        message,
      ];
}
