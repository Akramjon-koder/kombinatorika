# Problems — test plan

## 1. API test
- [ ] No backend. `ProblemBloc` saves results through `ProgressRepository.saveResult(problem.id, …)`.
- [ ] `test/problem_bloc_test.dart`: totals of all 20 problems, `Problem.ofGrade` numbering 1…10 with `previous`/`next`, grade-separated learners.

## 2. Mobile/Web integration test
- [ ] Chrome: open each of `/problem/11` … `/problem/20` as a 4th-grade learner, play to all variants, answer, get 3 stars; result appears on the city island and in the teacher table.

## 3. UI test
- [ ] Header pill shows the number inside the grade ("1-masala" for id 11).
- [ ] Pager dots / "Keyingi masala" stay inside the grade (no jump from 4th-grade #10 to anything).
- [ ] Each 4th-grade game fits at 360 px and 1500 px without overflow: trails, flower pots, snack bar, balloons, banknotes, digit cards, chess, parrots, ice cream, school shop.
- [ ] Trails: the walker walks there and back; the "go × return" table diagonal stays closed.

## 4. Logical/business test
- [ ] 1 Trails — same trail back is refused with a hint; 6 variants (ordered pairs).
- [ ] 2 Pots — swapping the two flowers of the double pot is a duplicate; 3 variants.
- [ ] 3 Snack bar — 3 × 4 = 12 cells.
- [ ] 4 Balloons — "Qizil + Ko‘k" = "Ko‘k + Qizil" (duplicate); 10 packs.
- [ ] 5 Banknotes — going over 10 000 is refused; "To‘lash" only at exactly 10 000; 10 ways.
- [ ] 6 Digit cards — a used card can't repeat in one number; 24 numbers.
- [ ] 7 Chess — "Ali — Vali" = "Vali — Ali"; both table cells fill; 10 games.
- [ ] 8 Parrots — third pick refused; 6 pairs.
- [ ] 9 Ice cream — needs container + flavour + topping; 12 orders.
- [ ] 10 School shop — baskets over 10 000 are refused ("pul yetmaydi"); exactly 10 000 (daftar + chizg‘ich + rangli qalamlar) is allowed; 5 purchases.
