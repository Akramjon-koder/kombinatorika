import 'package:flutter/material.dart';

import '../../../theme/apptheme.dart';

/// Which interactive mini-game renders the problem. Every problem in
/// `resources/masalalar tajriba.docx` gets its own individual mechanic.
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
  /// 1-based number, also the URL id (`/problem/3`).
  final int id;
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

  /// All problems of the worksheet in order.
  static List<Problem> get all => _problems;

  /// Looks a problem up by its id; `null` for unknown ids (bad URL).
  static Problem? byId(int? id) {
    for (final p in _problems) {
      if (p.id == id) return p;
    }
    return null;
  }
}

final List<Problem> _problems = [
  Problem(
    id: 1,
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
];
