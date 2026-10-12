import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../constants/string.dart';
import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';

/// Destructive-action confirmation before removing a learner's results.
Future<bool?> showConfirmDeleteDialog(BuildContext context, String name) => showDialog<bool>(
      context: context,
      barrierColor: theme.text.withValues(alpha: 0.45),
      builder: (context) => Dialog(
        backgroundColor: theme.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GlassCard(
            color: theme.white,
            padding: 26.all,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Emoji('🗑️', size: 54),
                12.height,
                Text(
                  Words.teacherDeleteQ.tr(args: [name]),
                  textAlign: TextAlign.center,
                  style: theme.display(22),
                ),
                22.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClayButton(
                      color: theme.textHint,
                      onTap: () => Navigator.of(context).pop(false),
                      child: Text(Words.no.tr()),
                    ),
                    14.width,
                    ClayButton(
                      color: theme.error,
                      onTap: () => Navigator.of(context).pop(true),
                      child: Text(Words.yes.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
