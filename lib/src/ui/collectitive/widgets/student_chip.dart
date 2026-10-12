import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../extensions/size_extensions.dart';
import '../../../network/progress_repository.dart';
import '../../../theme/apptheme.dart';
import '../model/student.dart';
import 'glass_card.dart';

/// Signed-in learner pill: avatar, name, solved count and total stars.
/// Reacts to [ProgressRepository.current] so stars update right after solving.
class StudentChip extends StatelessWidget {
  const StudentChip({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProgressRepository>();
    return ValueListenableBuilder<Student?>(
      valueListenable: repo.current,
      builder: (context, student, _) {
        if (student == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
          decoration: BoxDecoration(
            color: theme.glass,
            borderRadius: 30.circular,
            border: Border.all(color: theme.white, width: 2),
            boxShadow: theme.lifted(theme.primary, depth: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.secondary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Emoji(student.avatar, size: 28),
              ),
              10.width,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  student.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.display(20),
                ),
              ),
              14.width,
              const Emoji('⭐', size: 22),
              4.width,
              Text('${student.stars}', style: theme.display(20, color: theme.secondary)),
            ],
          ),
        );
      },
    );
  }
}

/// Row of 0…3 stars (filled / empty).
class StarRow extends StatelessWidget {
  final int stars;
  final double size;

  const StarRow({super.key, required this.stars, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            Icons.star_rounded,
            size: size,
            color: i < stars ? theme.star : theme.textHint.withValues(alpha: 0.45),
          ),
      ],
    );
  }
}
