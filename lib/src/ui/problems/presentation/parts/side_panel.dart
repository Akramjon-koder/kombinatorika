import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';

/// Right column: found-variants counter and list, the answer box with
/// "Tekshirish", and — once solved — the solution card.
class SidePanel extends StatelessWidget {
  final Problem problem;

  const SidePanel({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProblemBloc, ProblemState>(
      builder: (context, state) {
        return GlassCard(
          tint: theme.violet,
          padding: 16.all,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PillTitle(
                text: Words.foundTitle.tr(),
                color: theme.violet,
                leading: const Emoji('⭐', size: 20),
              ),
              14.height,
              _Counter(found: state.found.length, total: state.isSolved ? problem.total : null),
              12.height,
              _VariantList(state: state, color: problem.color),
              16.height,
              if (state.isSolved) ...[
                _Solution(problem: problem),
                12.height,
              ],
              _AnswerBox(problem: problem, solved: state.isSolved),
              12.height,
              ClayButton(
                color: theme.green,
                onTap: () => context.read<ProblemBloc>().add(const ProblemChecked()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded),
                    10.width,
                    Text(Words.check.tr()),
                  ],
                ),
              ),
              6.height,
              TextButton.icon(
                onPressed: () => context.read<ProblemBloc>().add(const ProblemReset()),
                icon: Icon(Icons.refresh_rounded, color: theme.textMuted),
                label: Text(Words.reset.tr(), style: theme.body(15, color: theme.textMuted)),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Big "3 / ?" counter. The total stays hidden until solved — counting is the
/// learner's job.
class _Counter extends StatelessWidget {
  final int found;
  final int? total;

  const _Counter({required this.found, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: theme.violet.withValues(alpha: 0.08),
        borderRadius: 20.circular,
        border: Border.all(color: theme.violet.withValues(alpha: 0.25), width: 2),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(found),
            tween: Tween(begin: 1.4, end: 1),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            builder: (context, s, child) => Transform.scale(scale: s, child: child),
            child: Text(
              '$found / ${total ?? '?'}',
              style: theme.display(46, color: theme.violet),
            ),
          ),
          Text(Words.foundCount.tr(), style: theme.body(15, color: theme.textMuted)),
        ],
      ),
    );
  }
}

class _VariantList extends StatelessWidget {
  final ProblemState state;
  final Color color;

  const _VariantList({required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    if (state.found.isEmpty) {
      return Container(
        padding: 18.all,
        decoration: BoxDecoration(
          color: theme.surfaceSubtle,
          borderRadius: 18.circular,
        ),
        child: Text(
          Words.foundEmpty.tr(),
          textAlign: TextAlign.center,
          style: theme.body(15, color: theme.textHint),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 290),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: state.found.length,
        separatorBuilder: (_, _) => 6.height,
        itemBuilder: (context, i) {
          final v = state.found[i];
          final flash = v.key == state.highlight;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: flash ? theme.star.withValues(alpha: 0.35) : theme.white,
              borderRadius: 14.circular,
              border: Border.all(color: flash ? theme.secondary : theme.line, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Text('${i + 1}', style: theme.display(15, color: theme.white)),
                ),
                10.width,
                for (final e in v.emojis) Emoji(e, size: 22),
                if (v.emojis.isNotEmpty) 8.width,
                Expanded(
                  child: Text(
                    v.label,
                    style: theme.body(15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// "Javob: [  ] ta taom".
class _AnswerBox extends StatefulWidget {
  final Problem problem;
  final bool solved;

  const _AnswerBox({required this.problem, required this.solved});

  @override
  State<_AnswerBox> createState() => _AnswerBoxState();
}

class _AnswerBoxState extends State<_AnswerBox> {
  late final TextEditingController _controller =
      TextEditingController(text: context.read<ProblemBloc>().state.answer);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProblemBloc, ProblemState>(
      // Reset clears the answer.
      listenWhen: (p, c) => p.round != c.round,
      listener: (context, state) => _controller.text = state.answer,
      child: Row(
        children: [
          Text('${Words.answerTitle.tr()}:', style: theme.display(22)),
          10.width,
          SizedBox(
            width: 92,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: theme.display(30, color: widget.solved ? theme.green : theme.primary),
              onChanged: (v) => context.read<ProblemBloc>().add(ProblemAnswerChanged(v)),
              onSubmitted: (_) => context.read<ProblemBloc>().add(const ProblemChecked()),
              decoration: InputDecoration(
                hintText: Words.answerHint.tr(),
                hintStyle: theme.body(15, color: theme.textHint),
                isDense: true,
                filled: true,
                fillColor: theme.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: 16.circular,
                  borderSide: BorderSide(
                    color: widget.solved ? theme.green : theme.slotBorder,
                    width: 2.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: 16.circular,
                  borderSide: BorderSide(color: theme.primary, width: 2.5),
                ),
              ),
            ),
          ),
          10.width,
          Flexible(
            child: Text(Words.answerUnit.tr(args: [widget.problem.unit]), style: theme.display(20, color: theme.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _Solution extends StatelessWidget {
  final Problem problem;

  const _Solution({required this.problem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 14.all,
      decoration: BoxDecoration(
        color: theme.green.withValues(alpha: 0.1),
        borderRadius: 18.circular,
        border: Border.all(color: theme.green.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Emoji('✅', size: 22),
              8.width,
              Text(Words.solution.tr(), style: theme.display(20, color: theme.green)),
            ],
          ),
          6.height,
          Text(problem.formula, style: theme.display(28, color: theme.text)),
          4.height,
          Text(problem.explanation, style: theme.body(14, color: theme.textMuted)),
        ],
      ),
    );
  }
}
