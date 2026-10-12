import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global theme tokens. Usage:
///
///   Text('...', style: TextStyle(color: theme.text));
///
/// Never hardcode `Color(0xFF…)` / `Colors.*` inside screens — add a token here.
final AppThemeData theme = AppThemeData();

/// Unified token class for the whole "Kombinatorika shahri" web app.
/// The palette is a bright, toy-like (clay / paper-cut 3D) kids palette.
class AppThemeData {
  // ── Brand ──────────────────────────────────────────────────────────────────
  /// Royal blue — "Kombinatorika" word, primary actions.
  final Color primary = const Color(0xFF1E5BD8);
  /// Sunny orange — "shahri" word, highlights.
  final Color secondary = const Color(0xFFFF9F1C);
  /// Candy pink — ribbons / subtitle pills.
  final Color pink = const Color(0xFFF0457E);
  /// Grape violet — teacher role, side panels.
  final Color violet = const Color(0xFF7B4DE8);
  /// Leaf green — learner role, success, "Tekshirish".
  final Color green = const Color(0xFF22B455);
  /// Sky cyan accents.
  final Color cyan = const Color(0xFF16B7E6);
  /// Lemon yellow — stars.
  final Color star = const Color(0xFFFFC300);
  /// Tomato red — errors, duplicates.
  final Color error = const Color(0xFFEF4444);
  /// Amber — hints / warnings.
  final Color amber = const Color(0xFFF59E0B);

  // ── Basic ──────────────────────────────────────────────────────────────────
  final Color white = const Color(0xFFFFFFFF);
  final Color black = const Color(0xFF000000);
  final Color transparent = const Color(0x00000000);

  // ── Text ───────────────────────────────────────────────────────────────────
  /// Deep navy body text.
  final Color text = const Color(0xFF1B2559);
  /// Muted body text.
  final Color textMuted = const Color(0xFF5B6487);
  /// Hint / placeholder text.
  final Color textHint = const Color(0xFF98A2C3);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  /// Frosted card surface.
  Color get glass => white.withValues(alpha: 0.88);
  /// Slightly tinted inner surface.
  final Color surfaceSubtle = const Color(0xFFF4F6FF);
  /// Dashed empty-slot border.
  final Color slotBorder = const Color(0xFFC7CDF2);
  /// Card outline.
  final Color line = const Color(0xFFE3E7FA);

  // ── Scene ──────────────────────────────────────────────────────────────────
  final Color skyTop = const Color(0xFF59B8FF);
  final Color skyBottom = const Color(0xFFCFEFFF);
  final Color grass = const Color(0xFF7DD35B);
  final Color grassDark = const Color(0xFF4FAE3A);
  final Color road = const Color(0xFFF6DDBE);
  final Color wood = const Color(0xFFB9783F);
  final Color woodLight = const Color(0xFFE2A866);
  final Color woodDark = const Color(0xFF7A4A22);
  final Color paper = const Color(0xFFFFF6E0);

  /// Pastel facades of the toy houses / flowers in the scene.
  final List<Color> pastel = const [
    Color(0xFFFFB4A2),
    Color(0xFFFFD166),
    Color(0xFFB5E48C),
    Color(0xFFA0C4FF),
    Color(0xFFCDB4DB),
    Color(0xFFFFADAD),
    Color(0xFF9BF6FF),
  ];

  // ── Picture palette (objects drawn by painters) ────────────────────────────
  final Color red = const Color(0xFFE53935);
  final Color blue = const Color(0xFF1E88E5);
  final Color yellow = const Color(0xFFFDD835);
  final Color greenObj = const Color(0xFF43A047);
  final Color orange = const Color(0xFFFB8C00);
  final Color mint = const Color(0xFF80CBC4);
  final Color grey = const Color(0xFF90A4AE);
  final Color skin = const Color(0xFFF6C9A0);
  final Color hair = const Color(0xFF4E342E);

  // ── Derived ────────────────────────────────────────────────────────────────
  /// Soft "lifted toy" shadow used by every 3D card.
  List<BoxShadow> lifted(Color tint, {double depth = 1}) => [
        BoxShadow(
          color: tint.withValues(alpha: 0.35),
          offset: Offset(0, 6 * depth),
          blurRadius: 0,
        ),
        BoxShadow(
          color: black.withValues(alpha: 0.12),
          offset: Offset(0, 14 * depth),
          blurRadius: 24 * depth,
        ),
      ];

  /// Bundled colour-emoji font family (see pubspec `fonts`).
  final String emojiFont = 'AppEmoji';

  /// Rounded display font (titles, big numbers).
  TextStyle display(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.baloo2(
        fontSize: size,
        color: color ?? text,
        fontWeight: weight ?? FontWeight.w800,
        height: 1.1,
      ).copyWith(fontFamilyFallback: [emojiFont]);

  /// Body font.
  TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.nunito(
        fontSize: size,
        color: color ?? text,
        fontWeight: weight ?? FontWeight.w700,
        height: 1.35,
      ).copyWith(fontFamilyFallback: [emojiFont]);

  /// Material theme for [MaterialApp].
  ThemeData get materialTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: skyBottom,
        primaryColor: primary,
        fontFamily: GoogleFonts.nunito().fontFamily,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          error: error,
          surface: white,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
            TargetPlatform.values,
            value: (_) => const FadeForwardsPageTransitionsBuilder(),
          ),
        ),
      );
}
