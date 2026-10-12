import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';

/// Pops a short coloured message ("Yangi variant!", "Bu variant bor!") from
/// [ProblemState.message] and hides it after a moment.
class ProblemToast extends StatefulWidget {
  const ProblemToast({super.key});

  @override
  State<ProblemToast> createState() => _ProblemToastState();
}

class _ProblemToastState extends State<ProblemToast> {
  ProblemMessage? _message;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(ProblemMessage m) {
    _timer?.cancel();
    setState(() => _message = m);
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => _message = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProblemBloc, ProblemState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) => _show(state.message!),
      child: IgnorePointer(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
              child: FadeTransition(opacity: a, child: child),
            ),
            child: _message == null ? const SizedBox.shrink() : _bubble(_message!),
          ),
        ),
      ),
    );
  }

  Widget _bubble(ProblemMessage m) {
    final (color, emoji) = switch (m.tone) {
      MessageTone.success => (theme.green, '🎉'),
      MessageTone.warning => (theme.amber, '🤔'),
      MessageTone.error => (theme.error, '🙈'),
      MessageTone.info => (theme.primary, '💡'),
    };
    return Container(
      key: ValueKey(m.seq),
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: 26.circular,
        border: Border.all(color: theme.white, width: 3),
        boxShadow: theme.lifted(color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Emoji(emoji, size: 30),
          12.width,
          Flexible(
            child: Text(
              m.translate ? m.text.tr() : m.text,
              style: theme.display(21, color: theme.white),
            ),
          ),
        ],
      ),
    );
  }
}
