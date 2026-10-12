part of 'bloc.dart';

sealed class ProblemEvent {
  const ProblemEvent();
}

/// A game produced a new variant (the bloc rejects duplicates).
final class ProblemVariantAdded extends ProblemEvent {
  final Variant variant;
  const ProblemVariantAdded(this.variant);
}

/// A variant was taken back (e.g. a pair was un-linked).
final class ProblemVariantRemoved extends ProblemEvent {
  final String key;
  const ProblemVariantRemoved(this.key);
}

/// The game owns the full variant list (painted houses) and replaces it.
final class ProblemVariantsSynced extends ProblemEvent {
  final List<Variant> variants;
  const ProblemVariantsSynced(this.variants);
}

/// A game-specific hint ("same colour twice!").
final class ProblemHintShown extends ProblemEvent {
  final String text;
  final MessageTone tone;
  const ProblemHintShown(this.text, {this.tone = MessageTone.warning});
}

final class ProblemAnswerChanged extends ProblemEvent {
  final String answer;
  const ProblemAnswerChanged(this.answer);
}

/// "Tekshirish" pressed.
final class ProblemChecked extends ProblemEvent {
  const ProblemChecked();
}

/// "Qaytadan" — clears variants and restarts the game round.
final class ProblemReset extends ProblemEvent {
  const ProblemReset();
}
