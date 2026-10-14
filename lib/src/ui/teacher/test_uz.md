# Teacher — test rejasi

## 1. API test
- [ ] Backend yo‘q. `ProgressRepository.students`ni o‘qiydi; `deleteStudent(student)` faqat o‘sha ism **va** sinfni o‘chiradi.

## 2. Mobile/Web integratsiya testi
- [ ] Chrome: ikkala sinf o‘quvchilari bo‘lganda `/teacher` "Barcha sinflar"da hammani ko‘rsatadi; "3-sinf" / "4-sinf" ikkala bo‘limni filtrlaydi.

## 3. UI test
- [ ] Natijalar, "Barcha sinflar": "Sinf" ustuni; masala ustunlari 1–10 raqamlangan (har o‘quvchining o‘z sinfidagi N-masala).
- [ ] Natijalar, bitta sinf: ustun sarlavhalarida o‘sha sinf masalalarining emojilari va joy nomi maslahatlari.
- [ ] O‘quvchisi yo‘q sinf "Bu sinfda hali hech kim o‘ynamagan." deb ko‘rsatadi; umuman o‘quvchi bo‘lmasa umumiy bo‘sh karta chiqadi.
- [ ] Javoblar: "Barcha sinflar" ikkala ish varag‘ini "3-sinf shahri" / "4-sinf shahri" ostida ko‘rsatadi; bitta sinf faqat o‘zining 10 ta kartasini.

## 4. Mantiqiy/biznes test
- [ ] "Ali" (3-sinf)ni o‘chirish "Ali" (4-sinf)ni qoldiradi; avval tasdiqlash dialogi.
- [ ] "Sinab ko‘rish" istalgan sinf masalasini ochadi (o‘qituvchi chiqqan, hech narsa saqlanmaydi).
