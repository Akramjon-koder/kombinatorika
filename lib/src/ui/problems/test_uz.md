# Problems — test rejasi

## 1. API test
- [ ] Backend yo‘q. `ProblemBloc` natijalarni `ProgressRepository.saveResult(problem.id, …)` orqali saqlaydi.
- [ ] `test/problem_bloc_test.dart`: 20 ta masalaning javoblari, `Problem.ofGrade` 1…10 raqamlash va `previous`/`next`, sinflar bo‘yicha ajratilgan o‘quvchilar.

## 2. Mobile/Web integratsiya testi
- [ ] Chrome: 4-sinf o‘quvchisi sifatida `/problem/11` … `/problem/20`ning har birini ochib, barcha variantlarni topish, javob yozish, 3 yulduz olish; natija shahar orolida va o‘qituvchi jadvalida ko‘rinadi.

## 3. UI test
- [ ] Sarlavha belgisi sinf ichidagi raqamni ko‘rsatadi (id 11 uchun "1-masala").
- [ ] Sahifa nuqtalari / "Keyingi masala" sinf ichida qoladi (4-sinf 10-masaladan keyin hech qayerga o‘tmaydi).
- [ ] Har bir 4-sinf o‘yini 360 px va 1500 px da toshmasdan sig‘adi: so‘qmoqlar, tuvaklar, bufet, sharlar, pullar, kartochkalar, shaxmat, to‘tiqushlar, muzqaymoq, do‘kon.
- [ ] So‘qmoqlar: sayohatchi borib-qaytadi; "borish × qaytish" jadvalining diagonali yopiq qoladi.

## 4. Mantiqiy/biznes test
- [ ] 1 So‘qmoqlar — o‘sha so‘qmoqdan qaytish maslahat bilan rad etiladi; 6 variant (tartibli juftliklar).
- [ ] 2 Tuvaklar — qo‘shaloq tuvakdagi ikki gulning o‘rnini almashtirish takror; 3 variant.
- [ ] 3 Bufet — 3 × 4 = 12 katak.
- [ ] 4 Sharlar — "Qizil + Ko‘k" = "Ko‘k + Qizil" (takror); 10 paket.
- [ ] 5 Pullar — 10 000 dan oshish rad etiladi; "To‘lash" faqat roppa-rosa 10 000 da; 10 usul.
- [ ] 6 Kartochkalar — ishlatilgan kartochka bir sonda takrorlanmaydi; 24 son.
- [ ] 7 Shaxmat — "Ali — Vali" = "Vali — Ali"; jadvalning ikkala katagi to‘ladi; 10 o‘yin.
- [ ] 8 To‘tiqushlar — uchinchi tanlov rad etiladi; 6 juftlik.
- [ ] 9 Muzqaymoq — idish + ta’m + sepma kerak; 12 buyurtma.
- [ ] 10 Do‘kon — 10 000 dan oshgan savat rad etiladi ("pul yetmaydi"); roppa-rosa 10 000 (daftar + chizg‘ich + rangli qalamlar) mumkin; 5 xarid.
