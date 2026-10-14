# Navigation map — Kombinatorika shahri

Router: `lib/src/router/web_router.dart` (go_router, path URL strategy).
Paths: `lib/src/constants/routes.dart`.

Web screens (lib/src/ui/)
 ├─ WelcomeScreen [Path: '/'] (welcome/presentation/welcome_screen.dart)
 │   └─ sign-in dialog: name + avatar → grade (3 / 4) (welcome/presentation/dialogs/sign_in_dialog.dart)
 ├─ CityScreen [Path: '/city'] (city/presentation/city_screen.dart)
 │   — the signed-in learner's grade city; redirects to '/' when nobody is signed in
 ├─ ProblemScreen [Path: '/problem/:id'] (problems/presentation/problem_screen.dart)
 │   — id 1–10: 3rd grade, id 11–20: 4th grade; an unknown id or another grade's
 │     problem (for a signed-in learner) redirects to '/city'
 └─ TeacherScreen [Path: '/teacher'] (teacher/presentation/teacher_screen.dart)
     — tabs "results" / "answer key", both filtered by grade (all / 3 / 4)
