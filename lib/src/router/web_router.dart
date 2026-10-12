import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../constants/routes.dart';
import '../network/progress_repository.dart';
import '../ui/city/presentation/city_screen.dart';
import '../ui/problems/model/problem.dart';
import '../ui/problems/presentation/problem_screen.dart';
import '../ui/teacher/presentation/teacher_screen.dart';
import '../ui/welcome/presentation/welcome_screen.dart';

/// Web router. The learner-only city map redirects to the welcome screen
/// while nobody is signed in; `refreshListenable` re-runs the
/// redirect on sign-in / sign-out.
GoRouter buildWebRouter(ProgressRepository progress) => GoRouter(
      initialLocation: Routes.welcome,
      refreshListenable: progress.current,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        // Problems stay open to the teacher (answer-key "try it"); results are
        // only stored for a signed-in learner.
        if (loc == Routes.city && progress.current.value == null) return Routes.welcome;
        return null;
      },
      routes: [
        GoRoute(
          path: Routes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: Routes.city,
          builder: (context, state) => const CityScreen(),
        ),
        GoRoute(
          path: Routes.problem,
          // Unknown id (bad / stale URL) → back to the city map.
          redirect: (context, state) =>
              Problem.byId(int.tryParse(state.pathParameters['id'] ?? '')) == null
                  ? Routes.city
                  : null,
          builder: (context, state) {
            final problem = Problem.byId(int.parse(state.pathParameters['id']!))!;
            return ProblemScreen(key: ValueKey(problem.id), problem: problem);
          },
        ),
        GoRoute(
          path: Routes.teacher,
          builder: (context, state) => const TeacherScreen(),
        ),
      ],
    );
