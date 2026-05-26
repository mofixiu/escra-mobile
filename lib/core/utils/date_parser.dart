import 'package:intl/intl.dart';

/// Clean utility to handle date and time formatting for escrow transaction lists and timeline history.
class DateParser {
  DateParser._();

  /// Formats a DateTime into a readable short date string.
  /// E.g., `DateTime.now()` -> `20 May 2026`
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  /// Formats a DateTime into full date and time.
  /// E.g., `20 May 2026, 09:30`
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  /// Returns a relative timestamp representation.
  /// E.g., `Just now`, `5m ago`, `2h ago`, `Yesterday` or date.
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return formatShortDate(dateTime);
    }
  }
}
