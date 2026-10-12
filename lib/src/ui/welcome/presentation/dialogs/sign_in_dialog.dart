import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../network/progress_repository.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';

/// Avatars a learner can pick.
const List<String> kAvatars = [
  '🧒🏻', '👧🏻', '👦🏽', '👧🏽', '🦸', '🧚', '🐱', '🐼', '🦊', '🐸', '🦁', '🐰',
];

/// Asks the learner's name + avatar and signs them in. Returns `true` when
/// signed in.
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

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> onTapGo() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    setState(() => _isLoading = true);
    await _repo.signIn(_name.text, _avatar);
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
          child: Column(
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
                onSubmitted: (_) => onTapGo(),
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
                  onTap: _isLoading ? null : onTapGo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Words.signInGo.tr()),
                      10.width,
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
