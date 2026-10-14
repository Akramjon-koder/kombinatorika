# Kombinatorika shahri

10 yoshli bolalar uchun kombinatorika masalalarini **sinab ko‘rib** yechadigan
Flutter Web o‘yin-sayt. Har sinfning o‘z shahri bor:
3-sinf — `resources/masalalar tajriba.docx` (10 ta), 4-sinf — `resources/masala tajriba 2.docx` (10 ta),
dizayn: `resources/11–14.jpg` + `~/Desktop/examplee.jpg` (qog‘oz-3D orollar).

## Buyruqlar

```bash
flutter run -d chrome          # ishlab chiqish
flutter build web --release    # build/web — istalgan statik hostingga
flutter analyze && flutter test
```

URL'lar path ko‘rinishida (`/city`, `/problem/3`) — hostingda barcha
yo‘llarni `index.html`ga yo‘naltiring (SPA fallback).

## Ekranlar

| URL | Ekran |
|-----|-------|
| `/` | Rol tanlash: O‘quvchi (ism + avatar → sinf: 3 / 4) / O‘qituvchi |
| `/city` | O‘quvchi sinfining shahri: 10 ta qog‘oz-3D orol, yulduzlar, progress |
| `/problem/:id` | Masala: shart + individual mini-o‘yin + variantlar paneli + javob. 3-sinf `id` 1–10, 4-sinf `id` 11–20; boshqa sinf masalasi o‘quvchini o‘z shahriga qaytaradi |
| `/teacher` | Sinf filtri (Barchasi / 3 / 4) + natijalar jadvali + javoblar va yechimlar |

To‘liq ro‘yxat: `lib/src/router/NAVIGATION_MAP.md`.

## Masalalar va mexanikalari

### 4-sinf (`masala tajriba 2.docx`, `id` 11–20)

| # | Joy | Mexanika | Javob |
|---|-----|----------|-------|
| 1 | Ko‘l so‘qmoqlari | Borish va boshqa qaytish so‘qmog‘i, sayohatchi yuradi; 3×3 jadval (diagonal yopiq) | 3×2=6 |
| 2 | Gul tuvaklar | Piyozlarni qo‘shaloq + bittalik tuvakka ekish, gullar ochiladi | 3 |
| 3 | Maktab bufeti | Sharbat × shirinlik, 3×4 jadval to‘ladi | 3×4=12 |
| 4 | Bayram sharlari | 2 xil rangli sharni sovg‘a paketiga bog‘lash | 10 |
| 5 | Pul hamyoni | 5000/2000/1000 lik pullar bilan roppa-rosa 10 000 to‘lash | 6+3+1=10 |
| 6 | Raqamli kartochkalar | 1–4 kartochkalardan uch xonali son, birinchi raqam bo‘yicha guruhlar | 4×3×2=24 |
| 7 | Shaxmat to‘garagi | 2 o‘quvchini tutashtirish + 5×5 o‘yinlar jadvali | 10 |
| 8 | To‘tiqushlar bog‘i | 2 to‘tiqushni katakka solish | 6 |
| 9 | Muzqaymoq do‘koni | Idish + ta’m + sepma → muzqaymoq quriladi | 2×3×2=12 |
| 10 | Maktab do‘koni | 3 xil narsa savatga; 10 000 dan oshsa «pul yetmaydi» | 5 |

### 3-sinf (`masalalar tajriba.docx`, `id` 1–10)

| # | Joy | Mexanika | Javob |
|---|-----|----------|-------|
| 1 | Maktab oshxonasi | Likopchaga taom + garnir, «taomlar daraxti» yonadi | 3×3=9 |
| 2 | Hasharotlar bog‘i | Diagonal kartochkaga 2 hasharot, albom; aylantirilgan karta — takror | 6 |
| 3 | Gilam do‘koni | 2 xil rangli o‘ralgan gilam → uyda yoyiladi | 3 |
| 4 | Nonushta stoli | Bo‘tqa × ichimlik, 3×3 jadval to‘ladi | 9 |
| 5 | Rangli uychalar | Bo‘yoq bilan tom/devor/deraza; bir xil uychalar qizil | 3×2×1=6 |
| 6 | Raqs maydoni | Bolalarni juftlash, juftliklar sahnada raqsga tushadi | 4 |
| 7 | Avtobus bekati | Rahbarni avtobusga sudrash | 6 |
| 8 | Yalangliklar xaritasi | 1–3 va 4–5 yo‘l, sayohatchi yuradi | 3×2=6 |
| 9 | Piknik | Sharbat + somsa → kod chiptasi (OG…), kod mashinasi | 2×2=4 |
| 10 | Choyxona | 2 finjonni chiziq bilan tutashtirish (K4 grafi) | 6 |

Yulduzlar: to‘g‘ri javob + barcha variantlar ko‘rsatilgan + xatosiz = ⭐⭐⭐.
Javob soni («0 / ?») yechilmaguncha yashirin.

## Tuzilma (my_mother uslubida)

```
lib/
├── main.dart, web.dart            # init, RepositoryProvider, MaterialApp.router
└── src/
    ├── constants/                  # routes.dart, string.dart (Words → uz.json)
    ├── extensions/size_extensions.dart
    ├── helpers/shared_service.dart
    ├── network/progress_repository.dart   # ValueNotifier, local storage
    ├── router/web_router.dart      # go_router
    ├── theme/apptheme.dart         # `theme.*` tokenlar
    └── ui/
        ├── collectitive/           # umumiy model + widgetlar (ClayButton, SceneBackground…)
        ├── welcome/ city/ teacher/ # bloc/ model/ presentation/{parts,dialogs,widgets}
        └── problems/
            ├── bloc/               # ProblemBloc (variantlar, tekshirish, natija)
            ├── model/problem.dart  # 2 × 10 masala: sinf, raqam, matn, javob, formula, izoh
            └── presentation/games/ # har masalaga alohida o‘yin + painters/
```

Natijalar shu brauzerning `shared_preferences`ida saqlanadi (backend yo‘q):
o‘qituvchi shu kompyuterda o‘ynagan o‘quvchilarni ko‘radi.

### Emoji shrifti

`assets/fonts/AppEmoji.ttf` — Noto Color Emoji (OFL) ning faqat ilovada
ishlatilgan emojilardan iborat qismi (~310 KB). Flutter Web ba'zi emojilarni
oq-qora chizgani uchun kerak. Yangi emoji qo‘shsangiz, shriftni
`pyftsubset` bilan qayta yig‘ing, aks holda u brauzer shriftida chiqadi.
