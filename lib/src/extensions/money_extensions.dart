/// Money formatting for the so‘m amounts shown in the games.
extension MoneyFormat on int {
  /// `10000` → `10 000` (thousands separated by a non-breaking space, so a
  /// number never wraps across lines).
  String get spaced {
    final digits = abs().toString();
    final buffer = StringBuffer(this < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// `1500` → `1 500 so‘m`.
  String get som => '$spaced\u00A0so‘m';
}
