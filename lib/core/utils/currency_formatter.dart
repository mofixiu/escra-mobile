import 'package:intl/intl.dart';

/// Enforces the 'Kobo Rule' for the ESCRA app.
/// Prevents IEEE floating point rounding errors in money mathematics by
/// handling all amounts internally as integer minor units (Kobo) and
/// only formatting to Naira strings inside the presentation layer.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _nairaFormat = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );

  /// Formats an integer amount of Kobo into a human-readable Naira String.
  /// E.g., `150000` -> `₦1,500.00`
  static String formatKobo(int amountKobo) {
    final double naira = amountKobo / 100.0;
    return _nairaFormat.format(naira);
  }

  /// Formats an integer amount of Kobo into a Naira String without decimal zeroes if they are .00.
  /// E.g., `150000` -> `₦1,500`, `150050` -> `₦1,500.50`
  static String formatKoboCompact(int amountKobo) {
    final double naira = amountKobo / 100.0;
    if (amountKobo % 100 == 0) {
      final compactFormat = NumberFormat.currency(
        locale: 'en_NG',
        symbol: '₦',
        decimalDigits: 0,
      );
      return compactFormat.format(naira);
    }
    return _nairaFormat.format(naira);
  }

  /// Converts a Naira double to integer Kobo, rounding to prevent floating point inaccuracies.
  /// E.g., `1500.50` -> `150050`
  static int nairaToKobo(double nairaAmount) {
    return (nairaAmount * 100.0).round();
  }
}
