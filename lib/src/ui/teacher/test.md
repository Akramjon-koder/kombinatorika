# Teacher — test plan

## 1. API test
- [ ] No backend. Reads `ProgressRepository.students`; `deleteStudent(student)` removes only that name **and** grade.

## 2. Mobile/Web integration test
- [ ] Chrome: with learners of both grades, `/teacher` shows everyone under "Barcha sinflar"; "3-sinf" / "4-sinf" filter both tabs.

## 3. UI test
- [ ] Results, "Barcha sinflar": a "Sinf" column; problem columns are numbered 1–10 (problem N of each learner's own grade).
- [ ] Results, one grade: column headers show that grade's problem emojis and place tooltips.
- [ ] A grade with no learners shows "Bu sinfda hali hech kim o‘ynamagan."; no learners at all shows the general empty card.
- [ ] Answer key: "Barcha sinflar" shows both worksheets under "3-sinf shahri" / "4-sinf shahri"; one grade shows only its 10 cards.

## 4. Logical/business test
- [ ] Deleting "Ali" (3-sinf) keeps "Ali" (4-sinf); confirmation dialog first.
- [ ] "Sinab ko‘rish" opens any grade's problem (teacher is signed out, nothing is saved).
