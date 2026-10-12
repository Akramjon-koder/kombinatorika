import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';

/// "Qanday o'ynash kerak?" — short rules of the game.
Future<void> showHowToPlayDialog(BuildContext context) => showDialog<void>(
      context: context,
      barrierColor: theme.text.withValues(alpha: 0.45),
      builder: (context) => Dialog(
        backgroundColor: theme.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: GlassCard(
            color: theme.white,
            padding: 28.all,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Emoji('💡', size: 64),
                Text(Words.cityHow.tr(), style: theme.display(30)),
                16.height,
                Text(Words.cityHowBody.tr(), style: theme.body(18)),
                24.height,
                ClayButton(
                  color: theme.green,
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(Words.understood.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
