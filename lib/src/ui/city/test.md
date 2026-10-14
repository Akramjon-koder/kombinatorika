# City — test plan

## 1. API test
- [ ] No backend. Islands come from `Problem.ofGrade(student.grade)`; stars from `student.results`.

## 2. Mobile/Web integration test
- [ ] Chrome: a 4th-grade learner sees the 4th-grade city (pink sky tint, "4-sinf shahri" badge); a 3rd-grade learner sees the original city.
- [ ] Opening `/city` signed out redirects to `/`.

## 3. UI test
- [ ] Wide (> 980 px): 10 islands on the treasure map, numbered 1–10 inside the grade.
- [ ] Narrow: islands wrap in a grid, no overflow at 360 px.
- [ ] Every island has its own decoration emojis rendered in colour (bundled `AppEmoji.ttf`).

## 4. Logical/business test
- [ ] Progress "X / 10" counts only the learner's grade problems.
- [ ] Typing `/problem/3` as a 4th-grade learner redirects to `/city` (another grade's problem).
