import 'package:flutter/material.dart';

import '../../../theme/apptheme.dart';
import '../../collectitive/model/grade.dart';

/// Which interactive mini-game renders the problem. Every problem of both
/// worksheets gets its own individual mechanic: 3rd grade —
/// `resources/masalalar tajriba.docx`, 4th grade — `resources/masala tajriba 2.docx`.
enum ProblemKind {
  /// 1 — Canteen: put a main dish + a side dish on a plate, a tree grows.
  canteen,

  /// 2 — Insect cards: fill the two diagonal halves of a card.
  insectCards,

  /// 3 — Carpet shop: unroll two carpets of different colours.
  carpets,

  /// 4 — Breakfast: porridge × drink table.
  breakfast,

  /// 5 — Paint houses: roof / wall / window with three paints.
  houses,

  /// 6 — Dance floor: split the children into pairs.
  dancers,

  /// 7 — Bus station: send the trip leader to a bus.
  buses,

  /// 8 — Meadow map: walk from A to B through the station.
  routes,

  /// 9 — Picnic: juice + samsa codes (OG, OK, …).
  picnic,

  /// 10 — Tea table: choose two of four cups, edges appear.
  cups,

  /// 4th grade 1 — Lake trails: go by one trail, come back by another.
  trails,

  /// 4th grade 2 — Flower pots: plant three bulbs into a double + a single pot.
  flowerPots,

  /// 4th grade 3 — Snack bar: one juice + one pastry, a 3 × 4 table fills.
  snackBar,

  /// 4th grade 4 — Balloons: tie two different colours into a gift pack.
  balloons,

  /// 4th grade 5 — Wallet: pay 10 000 so‘m with 1000 / 2000 / 5000 notes.
  banknotes,

  /// 4th grade 6 — Digit cards: build three-digit numbers from 1, 2, 3, 4.
  digitCards,

  /// 4th grade 7 — Chess club: every two of five players play one game.
  chess,

  /// 4th grade 8 — Parrots: put two of four parrots into the cage.
  parrots,

  /// 4th grade 9 — Ice-cream shop: container × flavour × topping.
  iceCream,

  /// 4th grade 10 — School shop: three different items within 10 000 so‘m.
  schoolShop,
}

/// One found variant. [key] is canonical (sorted when order does not matter)
/// so the bloc can detect duplicates; [label] is shown in the side panel and
/// [emojis] is the small picture of the variant.
@immutable
class Variant {
  final String key;
  final String label;
  final List<String> emojis;

  const Variant({required this.key, required this.label, this.emojis = const []});

  @override
  bool operator ==(Object other) => other is Variant && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Static description of a problem (content, not UI state).
@immutable
class Problem {
  /// Unique id across both grades, also the URL id (`/problem/3`).
  /// 3rd grade uses 1–10, 4th grade 11–20.
  final int id;

  /// Grade (worksheet) the problem belongs to.
  final Grade grade;

  /// 1-based number inside its grade's worksheet (shown to the learner).
  final int number;

  /// Mini-game that renders the problem.
  final ProblemKind kind;

  /// Location name in the city (sign on the plaque).
  final String place;

  /// Short tag under the place on the city map.
  final String tagline;

  /// Problem statement exactly as in the worksheet.
  final String statement;

  /// Total number of variants = correct answer.
  final int total;

  /// Short formula revealed after solving, e.g. `3 × 3 = 9`.
  final String formula;

  /// Child-friendly explanation revealed after solving.
  final String explanation;

  /// Mascot speech-bubble tip.
  final String tip;

  /// Big decoration emoji for the island / plaque.
  final String emoji;

  /// Accent colour of the location.
  final Color color;

  /// What a single variant is called ("taom", "kartochka", "yo'l", …).
  final String unit;

  const Problem({
    required this.id,
    required this.grade,
    required this.number,
    required this.kind,
    required this.place,
    required this.tagline,
    required this.statement,
    required this.total,
    required this.formula,
    required this.explanation,
    required this.tip,
    required this.emoji,
    required this.color,
    required this.unit,
  });

  /// All problems of both worksheets.
  static List<Problem> get all => _problems;

  /// Problems of [grade]'s worksheet in order.
  static List<Problem> ofGrade(Grade grade) =>
      _problems.where((p) => p.grade == grade).toList()..sort((a, b) => a.number.compareTo(b.number));

  /// Previous problem of the same worksheet, `null` for the first one.
  Problem? get previous => _sibling(-1);

  /// Next problem of the same worksheet, `null` for the last one.
  Problem? get next => _sibling(1);

  /// Problem [step] positions away inside the same worksheet.
  Problem? _sibling(int step) {
    for (final p in _problems) {
      if (p.grade == grade && p.number == number + step) return p;
    }
    return null;
  }

  /// Looks a problem up by its id; `null` for unknown ids (bad URL).
  static Problem? byId(int? id) {
    for (final p in _problems) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Every problem of both worksheets (3rd grade first, then 4th grade).
final List<Problem> _problems = [
  Problem(
    id: 1,
    grade: Grade.third,
    number: 1,
    kind: ProblemKind.canteen,
    place: 'Maktab oshxonasi',
    tagline: 'Taom + garnir',
    statement:
        'Maktab oshxonasi menyusida kotletlar, sosiska va qovurilgan tuxum bor. '
        'Garnir uchun sabzavot, makaron va kartoshka pyuresini tanlash mumkin. '
        'Maktab o‘quvchisi ushbu to‘plamdan qancha turli xil taomlar tuzishi mumkin?',
    total: 9,
    formula: '3 × 3 = 9',
    explanation:
        'Har bir asosiy taomga 3 xil garnir mos keladi. Asosiy taom 3 ta — '
        'demak daraxtda 3 ta shox, har shoxda 3 tadan barg: 3 + 3 + 3 = 9.',
    tip: 'Avval asosiy taomni, keyin garnirni likopchaga qo‘y!',
    emoji: '🍽️',
    color: theme.orange,
    unit: 'taom',
  ),
  Problem(
    id: 2,
    grade: Grade.third,
    number: 2,
    kind: ProblemKind.insectCards,
    place: 'Hasharotlar bog‘i',
    tagline: 'Kartochkalar to‘plami',
    statement:
        'Umidada 4 ta hasharot rasmi — qo‘ng‘iz, kapalak, xonqizi va pashsha '
        'chizilgan kartochkalar bor. Har bir kartochkada 2 ta hasharot tasvirlangan. '
        'To‘plamda nechta har xil kartochka bo‘lishi mumkin?',
    total: 6,
    formula: '3 + 2 + 1 = 6',
    explanation:
        'Qo‘ng‘iz qolgan 3 ta bilan juftlashadi, kapalak — yana 2 ta yangi, '
        'xonqizi — 1 ta yangi. “Kapalak + qo‘ng‘iz” bilan “qo‘ng‘iz + kapalak” — '
        'bitta kartochka!',
    tip: 'Kartochkani aylantirsang ham u o‘sha kartochka bo‘lib qoladi!',
    emoji: '🦋',
    color: theme.greenObj,
    unit: 'kartochka',
  ),
  Problem(
    id: 3,
    grade: Grade.third,
    number: 3,
    kind: ProblemKind.carpets,
    place: 'Gilam do‘koni',
    tagline: 'Ikki xil rang',
    statement:
        'Do‘konda qizil, ko‘k va kulrang gilam bor. Xaridor turli rangdagi ikkita '
        'gilam sotib oldi. Gilamlar qanday ranglarda bo‘lishi mumkin. '
        'Sizda nechta variant hosil bo‘ldi?',
    total: 3,
    formula: '2 + 1 = 3',
    explanation:
        'Qizil gilamni ko‘k yoki kulrang bilan olish mumkin (2 ta), ko‘k bilan '
        'kulrang — yana 1 ta. Hammasi 3 ta xarid.',
    tip: 'Ikkita turli rangdagi gilamni bos — ular xaridor uyiga yoyiladi!',
    emoji: '🧶',
    color: theme.red,
    unit: 'xarid',
  ),
  Problem(
    id: 4,
    grade: Grade.third,
    number: 4,
    kind: ProblemKind.breakfast,
    place: 'Nonushta stoli',
    tagline: 'Bo‘tqa va ichimlik',
    statement:
        'Maktabda o‘quvchi ertalabki nonushtaga qora bug‘doy, manniy yoki suli '
        'bo‘tqasidan birini, ichishga choy, qatiq yoki sharbatdan birini tanlashi '
        'mumkin. Ertalabki nonushta uchun mumkin bo‘lgan barcha taomlar juftligini yozing.',
    total: 9,
    formula: '3 × 3 = 9',
    explanation:
        'Jadvalda 3 ta qator (bo‘tqalar) va 3 ta ustun (ichimliklar) bor. '
        'Har bir katak — bitta nonushta: 3 × 3 = 9 ta katak.',
    tip: 'Bo‘tqani va ichimlikni tanla — jadvaldagi katak to‘ladi!',
    emoji: '🥣',
    color: theme.amber,
    unit: 'nonushta',
  ),
  Problem(
    id: 5,
    grade: Grade.third,
    number: 5,
    kind: ProblemKind.houses,
    place: 'Rangli uychalar',
    tagline: 'Uch xil bo‘yoq',
    statement:
        'Uycha qismlarini (tom, devor, deraza) uch xil rangdan foydalanib '
        'shunday bo‘yangki, birorta ham bir xil uycha bo‘lmasin.',
    total: 6,
    formula: '3 × 2 × 1 = 6',
    explanation:
        'Tomga 3 ta rangdan birini tanlaymiz, devorga qolgan 2 tadan birini, '
        'derazaga esa oxirgi 1 ta rang qoladi: 3 × 2 × 1 = 6 ta har xil uycha.',
    tip: 'Har bir uychada uchala rang ham bo‘lsin. Bir xil uycha bo‘lmasin!',
    emoji: '🏠',
    color: theme.cyan,
    unit: 'uycha',
  ),
  Problem(
    id: 6,
    grade: Grade.third,
    number: 6,
    kind: ProblemKind.dancers,
    place: 'Raqs maydoni',
    tagline: 'Juftliklar',
    statement: 'Bolalarni juftliklarga ajrating. Nechta juftlik hosil bo‘ldi?',
    total: 4,
    formula: '8 : 2 = 4',
    explanation:
        'Maydonda 8 ta bola bor. Har bir juftlikda 2 ta bola: 8 ni 2 ga bo‘lsak, '
        '4 ta juftlik hosil bo‘ladi.',
    tip: 'Bir bolani, keyin ikkinchisini bos — ular qo‘l ushlashadi!',
    emoji: '💃',
    color: theme.pink,
    unit: 'juftlik',
  ),
  Problem(
    id: 7,
    grade: Grade.third,
    number: 7,
    kind: ProblemKind.buses,
    place: 'Avtobus bekati',
    tagline: 'Sayr rahbari',
    statement:
        'O‘quvchilarni avtobusda sayrga olib borishdi. Sayr rahbari istagan '
        'avtobusda ketishi mumkin. Rahbarda avtobus tanlashda nechta imkoniyat bor?',
    total: 6,
    formula: '6 ta avtobus = 6 imkoniyat',
    explanation:
        'Rahbar faqat bitta avtobusni tanlaydi. Nechta avtobus bo‘lsa, shuncha '
        'imkoniyat bor — 6 ta.',
    tip: 'Rahbarni avtobusga sudrab olib bor yoki avtobusni bos!',
    emoji: '🚌',
    color: theme.violet,
    unit: 'imkoniyat',
  ),
  Problem(
    id: 8,
    grade: Grade.third,
    number: 8,
    kind: ProblemKind.routes,
    place: 'Yalangliklar xaritasi',
    tagline: 'A dan B ga yo‘llar',
    statement:
        'O‘quvchilar sayrda A yalanglikdan B yalanglikka o‘tishlari kerak. '
        'Barcha mumkin bo‘lgan yo‘llarni yozing. Namuna: 1 → 4',
    total: 6,
    formula: '3 × 2 = 6',
    explanation:
        'A dan bekatgacha 3 ta yo‘l (1, 2, 3), bekatdan B gacha 2 ta yo‘l (4, 5). '
        'Har bir birinchi yo‘lni 2 xil davom ettirish mumkin: 3 × 2 = 6.',
    tip: 'Avval A dan bekatgacha yo‘lni, keyin bekatdan B gacha yo‘lni tanla.',
    emoji: '🗺️',
    color: theme.grassDark,
    unit: 'yo‘l',
  ),
  Problem(
    id: 9,
    grade: Grade.third,
    number: 9,
    kind: ProblemKind.picnic,
    place: 'Piknik savatchasi',
    tagline: 'Sharbat + somsa',
    statement:
        'Sayrning oxirida har bir o‘quvchiga sharbat va somsa tarqatildi. '
        'Sharbat olmali (O) va apelsinli (A), somsa go‘shtli (G) va kartoshkali (K) '
        'edi. Sharbat va somsalarni tanlashning necha xil usulini tuzish mumkin? Namuna: OG',
    total: 4,
    formula: '2 × 2 = 4',
    explanation:
        'Sharbat 2 xil, somsa 2 xil. Har bir sharbatga 2 xil somsa: '
        'OG, OK, AG, AK — 2 × 2 = 4 usul.',
    tip: 'Sharbat va somsani savatchaga sol — kodi o‘zi chiqadi!',
    emoji: '🧃',
    color: theme.secondary,
    unit: 'usul',
  ),
  Problem(
    id: 10,
    grade: Grade.third,
    number: 10,
    kind: ProblemKind.cups,
    place: 'Choyxona',
    tagline: '4 tadan 2 ta finjon',
    statement:
        'Aziz 4 ta finjon qo‘yilgan stolga o‘tirdi. U 2 ta finjonni necha usulda '
        'tanlashi mumkin? Tasvirlang.',
    total: 6,
    formula: '3 + 2 + 1 = 6',
    explanation:
        'Har bir tanlovni ikki finjon orasidagi chiziq bilan tasvirladik. '
        '4 ta nuqtani juft-juft tutashtiruvchi chiziqlar soni: 3 + 2 + 1 = 6.',
    tip: 'Ikkita finjonni bos — ular orasida chiziq paydo bo‘ladi.',
    emoji: '☕',
    color: theme.primary,
    unit: 'usul',
  ),
  Problem(
    id: 11,
    grade: Grade.fourth,
    number: 1,
    kind: ProblemKind.trails,
    place: 'Ko‘l so‘qmoqlari',
    tagline: 'Borish va qaytish',
    statement:
        'Qishloqdan ko‘lgacha uchta so‘qmoq orqali borish mumkin. Abdulmalik '
        'ko‘lgacha bir so‘qmoq orqali borib, boshqasi orqali qaytmoqchi. '
        'Buni nechta usulda bajarish mumkin?',
    total: 6,
    formula: '3 × 2 = 6',
    explanation:
        'Borish uchun 3 ta so‘qmoqdan birini tanlaymiz. Qaytishda o‘sha '
        'so‘qmoq bo‘lmaydi — qolgan 2 tadan biri. Har bir borishga 2 xil qaytish: 3 × 2 = 6.',
    tip: 'Avval borish so‘qmog‘ini, keyin boshqa qaytish so‘qmog‘ini bos!',
    emoji: '🏞️',
    color: theme.cyan,
    unit: 'usul',
  ),
  Problem(
    id: 12,
    grade: Grade.fourth,
    number: 2,
    kind: ProblemKind.flowerPots,
    place: 'Gul tuvaklar',
    tagline: 'Qo‘shaloq va bittalik',
    statement:
        'Masturaning gullar uchun qo‘shaloq va bittalik gultuvaklari bor. '
        'Ularga sumbula, krokus va lola piyozlarini ekmoqchi. '
        'Mastura buni necha usulda amalga oshirishi mumkin?',
    total: 3,
    formula: '1 + 1 + 1 = 3',
    explanation:
        'Bittalik tuvakka 3 ta piyozdan bittasini ekamiz, qolgan ikkitasi qo‘shaloq '
        'tuvakka tushadi. Qo‘shaloq tuvakda gullarning o‘rni almashsa ham ekish '
        'o‘zgarmaydi. Bittalik tuvakda sumbula, krokus yoki lola — 3 usul.',
    tip: 'Qo‘shaloq tuvakda gullarning o‘rnini almashtirish — yangi usul emas!',
    emoji: '🪴',
    color: theme.greenObj,
    unit: 'usul',
  ),
  Problem(
    id: 13,
    grade: Grade.fourth,
    number: 3,
    kind: ProblemKind.snackBar,
    place: 'Maktab bufeti',
    tagline: 'Sharbat + shirinlik',
    statement:
        'Oshxonada olma, shaftoli va anor sharbatlari hamda bulochka, somsa, pirog '
        'va pechenye sotiladi. Ruxsora tanaffusda bitta sharbat va bitta shirinlik '
        'sotib olmoqchi. U necha xil nonushta to‘plamini tanlashi mumkin?',
    total: 12,
    formula: '3 × 4 = 12',
    explanation:
        'Jadvalda 3 ta qator (sharbatlar) va 4 ta ustun (shirinliklar). '
        'Har bir katak — bitta to‘plam: 3 × 4 = 12.',
    tip: 'Sharbat va shirinlikni tanla — jadvaldagi katak to‘ladi!',
    emoji: '🥐',
    color: theme.orange,
    unit: 'to‘plam',
  ),
  Problem(
    id: 14,
    grade: Grade.fourth,
    number: 4,
    kind: ProblemKind.balloons,
    place: 'Bayram sharlari',
    tagline: '5 rangdan 2 tasi',
    statement:
        'Bayram uchun qizil, ko‘k, sariq, yashil va oq rangli sharlar tayyorlandi. '
        'Har bir sovg‘a paketiga 2 ta turli rangdagi shar solinadi. '
        'Necha xil sovg‘a paketini tayyorlash mumkin?',
    total: 10,
    formula: '4 + 3 + 2 + 1 = 10',
    explanation:
        'Qizil shar qolgan 4 ta rang bilan juftlashadi, ko‘k — yana 3 ta yangi, '
        'sariq — 2 ta, yashil — 1 ta. “Qizil + ko‘k” va “ko‘k + qizil” — bitta paket!',
    tip: 'Ikkita turli rangli sharni bos — ular paketga bog‘lanadi.',
    emoji: '🎈',
    color: theme.pink,
    unit: 'paket',
  ),
  Problem(
    id: 15,
    grade: Grade.fourth,
    number: 5,
    kind: ProblemKind.banknotes,
    place: 'Pul hamyoni',
    tagline: '10\u00A0000 so‘m to‘lash',
    statement:
        'Akmal 10\u00A0000 so‘mni 1000, 2000 va 5000 so‘mlik qog‘oz pullar bilan to‘lamoqchi '
        '(har bir turdagi puldan istalgancha ishlatish mumkin, ba’zi turlarini umuman '
        'ishlatmasa ham bo‘ladi). Buni necha xil usulda qilish mumkin?',
    total: 10,
    formula: '6 + 3 + 1 = 10',
    explanation:
        '5000 likni ishlatmasak: 2000 lik 0, 1, 2, 3, 4 yoki 5 ta — 6 usul. '
        'Bitta 5000 lik bilan qolgan 5000 ni: 2000 lik 0, 1 yoki 2 ta — 3 usul. '
        'Ikkita 5000 lik — 1 usul. Jami 6 + 3 + 1 = 10.',
    tip: 'Pullarni hamyonga qo‘sh — roppa-rosa 10\u00A0000 bo‘lsa, to‘la!',
    emoji: '💵',
    color: theme.grassDark,
    unit: 'usul',
  ),
  Problem(
    id: 16,
    grade: Grade.fourth,
    number: 6,
    kind: ProblemKind.digitCards,
    place: 'Raqamli kartochkalar',
    tagline: 'Uch xonali sonlar',
    statement:
        '1, 2, 3 va 4 raqamlari yozilgan to‘rtta kartochka bor. Shu kartochkalardan '
        'raqamlari takrorlanmaydigan nechta uch xonali son tuzish mumkin?',
    total: 24,
    formula: '4 × 3 × 2 = 24',
    explanation:
        'Yuzlar xonasiga 4 ta raqamdan biri, o‘nlar xonasiga qolgan 3 tadan biri, '
        'birlar xonasiga qolgan 2 tadan biri: 4 × 3 × 2 = 24 ta son.',
    tip: 'Kartochkalarni bos — ular yuzlar, o‘nlar, birlar xonasiga tushadi.',
    emoji: '🔢',
    color: theme.primary,
    unit: 'son',
  ),
  Problem(
    id: 17,
    grade: Grade.fourth,
    number: 7,
    kind: ProblemKind.chess,
    place: 'Shaxmat to‘garagi',
    tagline: 'Har kim har kim bilan',
    statement:
        'Shaxmat to‘garagiga 5 nafar o‘quvchi keldi. Ularning har biri qolgan hamma '
        'bilan bittadan o‘yin o‘ynadi. Jami necha o‘yin bo‘lgan?',
    total: 10,
    formula: '4 + 3 + 2 + 1 = 10',
    explanation:
        'Birinchi o‘quvchi 4 kishi bilan o‘ynaydi, ikkinchisi yana 3 ta yangi o‘yin, '
        'uchinchisi — 2 ta, to‘rtinchisi — 1 ta. “Ali — Vali” va “Vali — Ali” — bitta o‘yin!',
    tip: 'Ikkita o‘quvchini bos — ular orasida shaxmat o‘yini boshlanadi.',
    emoji: '♟️',
    color: theme.violet,
    unit: 'o‘yin',
  ),
  Problem(
    id: 18,
    grade: Grade.fourth,
    number: 8,
    kind: ProblemKind.parrots,
    place: 'To‘tiqushlar bog‘i',
    tagline: '4 tadan 2 tasi',
    statement:
        'Katakka solish uchun ikkita to‘tiqushni tanlab oling. '
        'Buni necha usulda amalga oshira olasiz?',
    total: 6,
    formula: '3 + 2 + 1 = 6',
    explanation:
        'To‘tiqushlar 4 ta. Birinchisi qolgan 3 tasi bilan, ikkinchisi yana 2 ta yangi, '
        'uchinchisi — 1 ta yangi juftlik hosil qiladi: 3 + 2 + 1 = 6.',
    tip: 'Ikkita to‘tiqushni bos va katakka sol!',
    emoji: '🦜',
    color: theme.red,
    unit: 'usul',
  ),
  Problem(
    id: 19,
    grade: Grade.fourth,
    number: 9,
    kind: ProblemKind.iceCream,
    place: 'Muzqaymoq do‘koni',
    tagline: 'Idish × ta’m × sepma',
    statement:
        'Muzqaymoq do‘konida 2 xil idish (konus, stakan), 3 xil ta’m (vanil, shokolad, '
        'qulupnay) va 2 xil sepma (yong‘oq, rangli sepma) bor. Sardor bitta idish, bitta '
        'ta’m va bitta sepmani tanlab, muzqaymoq buyurtma qilmoqchi. '
        'U necha xil muzqaymoq buyurtma qilishi mumkin?',
    total: 12,
    formula: '2 × 3 × 2 = 12',
    explanation:
        'Har bir idishga 3 xil ta’m — 2 × 3 = 6 xil. Har biriga 2 xil sepma: '
        '6 × 2 = 12 xil muzqaymoq.',
    tip: 'Idish, ta’m va sepmani tanla — muzqaymoq tayyor!',
    emoji: '🍦',
    color: theme.amber,
    unit: 'xil',
  ),
  Problem(
    id: 20,
    grade: Grade.fourth,
    number: 10,
    kind: ProblemKind.schoolShop,
    place: 'Maktab do‘koni',
    tagline: '10\u00A0000 so‘mga 3 ta narsa',
    statement:
        'Azizning cho‘ntagida 10\u00A0000 so‘m pul bor. U maktab do‘konidan uchta turli narsa '
        'sotib olmoqchi. Aziz pulga qarab nimalarni sotib olishi mumkin? Barcha variantlarni '
        'toping. Narxlar: qalam — 1\u00A0500, daftar — 3\u00A0000, chizg‘ich — 2\u00A0000, rangli qalamlar '
        'to‘plami — 5\u00A0000, penal — 6\u00A0000 so‘m.',
    total: 5,
    formula: '5 ta xarid',
    explanation:
        'Qalam + daftar + chizg‘ich = 6\u00A0500; qalam + daftar + rangli qalamlar = 9\u00A0500; '
        'qalam + chizg‘ich + rangli qalamlar = 8\u00A0500; qalam + chizg‘ich + penal = 9\u00A0500; '
        'daftar + chizg‘ich + rangli qalamlar = 10\u00A0000. Qolgan uchliklarga pul yetmaydi.',
    tip: '3 ta narsani savatga sol — narxlar yig‘indisi 10\u00A0000 dan oshmasin!',
    emoji: '🛒',
    color: theme.blue,
    unit: 'xarid',
  ),
];
