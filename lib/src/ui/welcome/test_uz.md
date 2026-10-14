# Welcome — test rejasi

## 1. API test
- [ ] Backend yo‘q. `ProgressRepository.signIn(name, avatar, grade)` o‘quvchini `shared_preferences`ga saqlaydi (`students`, `current_student`, `current_grade`).
- [ ] 3-sinfda "Ali" va 4-sinfda "ali" bilan kirish ikki xil yozuv yaratadi; 3-sinfda yana "ALI" bilan kirish birinchisini qayta ishlatadi.

## 2. Mobile/Web integratsiya testi
- [ ] Chrome: `/` → "O‘quvchi" → ism → "Davom etish" → "4-sinf" → 4-sinf orollari bilan `/city`ga o‘tadi, konsolda xato yo‘q.
- [ ] Kirgandan keyin `/city`ni qayta yuklash o‘sha o‘quvchi va sinfni saqlaydi.

## 3. UI test
- [ ] Bo‘sh ism + "Davom etish" qizil xatoni ko‘rsatadi; yozish uni o‘chiradi.
- [ ] Sinf qadami: ikkita karta (3-sinf, 4-sinf), "Orqaga" ism saqlangan holda ism qadamiga qaytaradi.
- [ ] Dialog 360 px kenglikda (sinf kartalari pastga tushadi) va 1920 px da sig‘adi.

## 4. Mantiqiy/biznes test
- [ ] "O‘qituvchi" `/teacher`ni ochishdan oldin o‘quvchini chiqaradi.
- [ ] Eski ma’lumotlar (sinflar paydo bo‘lishidan oldin saqlangan o‘quvchilar) 3-sinf sifatida ochiladi.
