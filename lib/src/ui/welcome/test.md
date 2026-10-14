# Welcome — test plan

## 1. API test
- [ ] No backend. `ProgressRepository.signIn(name, avatar, grade)` stores the learner in `shared_preferences` (`students`, `current_student`, `current_grade`).
- [ ] Signing in "Ali" in grade 3 and "ali" in grade 4 creates two records; signing in "ALI" in grade 3 again reuses the first one.

## 2. Mobile/Web integration test
- [ ] Chrome: `/` → "O‘quvchi" → name → "Davom etish" → "4-sinf" → lands on `/city` with the 4th-grade islands, no console errors.
- [ ] Reload `/city` after sign-in keeps the same learner and grade.

## 3. UI test
- [ ] Empty name + "Davom etish" shows the red error; typing clears it.
- [ ] Grade step: two cards (3-sinf, 4-sinf), "Orqaga" returns to the name step with the name kept.
- [ ] Dialog fits at 360 px width (grade cards wrap) and at 1920 px.

## 4. Logical/business test
- [ ] "O‘qituvchi" signs the learner out before opening `/teacher`.
- [ ] Legacy data (students saved before grades existed) opens as 3rd grade.
