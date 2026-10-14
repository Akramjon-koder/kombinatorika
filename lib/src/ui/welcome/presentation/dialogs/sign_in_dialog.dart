import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../network/progress_repository.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/model/grade.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';

/// Avatars a learner can pick.
const List<String> kAvatars = [
  '🧒🏻', '👧🏻', '👦🏽', '👧🏽', '🦸', '🧚', '🐱', '🐼', '🦊', '🐸', '🦁', '🐰',
];

/// Two steps: the learner's name + avatar, then the grade (each grade has its
/// own city). Signs them in and returns `true` when done.
Future<bool?> showSignInDialog(BuildContext context) => showDialog<bool>(
      context: context,
      barrierColor: theme.text.withValues(alpha: 0.45),
      builder: (_) => const _SignInDialog(),
    );

class _SignInDialog extends StatefulWidget {
  const _SignInDialog();

  @override
  State<_SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<_SignInDialog> {
  late final ProgressRepository _repo = context.read<ProgressRepository>();
  late final TextEditingController _name =
      TextEditingController(text: _repo.current.value?.name ?? '');
  late String _avatar = _repo.current.value?.avatar ?? kAvatars.first;
  bool _hasError = false;
  bool _isLoading = false;

  /// `false` — name + avatar step, `true` — grade step.
  bool _isGradeStep = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Validates the name and moves on to the grade step.
  void onTapNext() {
    if (_name.text.trim().isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    setState(() => _isGradeStep = true);
  }

  /// Signs the learner into [grade]'s city.
  Future<void> onTapGrade(Grade grade) async {
    setState(() => _isLoading = true);
    await _repo.signIn(_name.text, _avatar, grade);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: theme.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassCard(
          color: theme.white,
          padding: 28.all,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _isGradeStep ? _gradeStep() : _nameStep(),
          ),
        ),
      ),
    );
  }

  /// Step 1: name field + avatar grid.
  Widget _nameStep() {
    return Column(
      key: const ValueKey('name'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Emoji(_avatar, size: 84),
        8.height,
        Text(Words.signInTitle.tr(), style: theme.display(32)),
        20.height,
        TextField(
          controller: _name,
          autofocus: true,
          textAlign: TextAlign.center,
          style: theme.display(26),
          onSubmitted: (_) => onTapNext(),
          onChanged: (_) {
            if (_hasError) setState(() => _hasError = false);
          },
          decoration: InputDecoration(
            hintText: Words.signInName.tr(),
            hintStyle: theme.display(24, color: theme.textHint),
            errorText: _hasError ? Words.signInEmpty.tr() : null,
            filled: true,
            fillColor: theme.surfaceSubtle,
            border: OutlineInputBorder(
              borderRadius: 20.circular,
              borderSide: BorderSide.none,
            ),
          ),
        ),
        20.height,
        Text(Words.signInAvatar.tr(), style: theme.body(16, color: theme.textMuted)),
        10.height,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final a in kAvatars)
              GestureDetector(
                onTap: () => setState(() => _avatar = a),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: a == _avatar
                        ? theme.secondary.withValues(alpha: 0.2)
                        : theme.surfaceSubtle,
                    borderRadius: 18.circular,
                    border: Border.all(
                      color: a == _avatar ? theme.secondary : theme.transparent,
                      width: 3,
                    ),
                  ),
                  child: Emoji(a, size: 32),
                ),
              ),
          ],
        ),
        26.height,
        SizedBox(
          width: double.infinity,
          child: ClayButton(
            color: theme.green,
            onTap: onTapNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Words.signInNext.tr()),
                10.width,
                const Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Step 2: one big card per grade; tapping one signs in.
  Widget _gradeStep() {
    return Column(
      key: const ValueKey('grade'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Emoji(_avatar, size: 64),
        8.height,
        Text(Words.gradeTitle.tr(), textAlign: TextAlign.center, style: theme.display(30)),
        4.height,
        Text(Words.gradeSub.tr(), style: theme.body(16, color: theme.textMuted)),
        22.height,
        Wrap(
          spacing: 16,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: [
            for (final g in Grade.values)
              SizedBox(
                width: 200,
                child: ClayButton(
                  color: g.color,
                  radius: 28,
                  depth: 8,
                  onTap: _isLoading ? null : () => onTapGrade(g),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    children: [
                      Emoji(g.emoji, size: 48),
                      6.height,
                      Text(Words.gradeN.tr(args: ['${g.number}']), style: theme.display(34, color: theme.white)),
                      Text(
                        Words.gradeCity.tr(args: ['${g.number}']),
                        style: theme.body(14, color: theme.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        14.height,
        TextButton.icon(
          onPressed: _isLoading ? null : () => setState(() => _isGradeStep = false),
          icon: Icon(Icons.arrow_back_rounded, color: theme.textMuted),
          label: Text(Words.back.tr(), style: theme.body(15, color: theme.textMuted)),
        ),
      ],
    );
  }
}
