# City — test rejasi

## 1. API test
- [ ] Backend yo‘q. Orollar `Problem.ofGrade(student.grade)`dan; yulduzlar `student.results`dan olinadi.

## 2. Mobile/Web integratsiya testi
- [ ] Chrome: 4-sinf o‘quvchisi 4-sinf shahrini ko‘radi (pushti osmon, "4-sinf shahri" belgisi); 3-sinf o‘quvchisi asl shaharni ko‘radi.
- [ ] Chiqib turgan holda `/city`ni ochish `/`ga yo‘naltiradi.

## 3. UI test
- [ ] Keng (> 980 px): xaritada 10 ta orol, sinf ichida 1–10 raqamlangan.
- [ ] Tor: orollar to‘rga tushadi, 360 px da toshib ketish yo‘q.
- [ ] Har bir orolning bezak emojilari rangli chiqadi (ilovadagi `AppEmoji.ttf`).

## 4. Mantiqiy/biznes test
- [ ] "X / 10" progress faqat o‘quvchi sinfining masalalarini sanaydi.
- [ ] 4-sinf o‘quvchisi `/problem/3`ni yozsa `/city`ga qaytariladi (boshqa sinf masalasi).
