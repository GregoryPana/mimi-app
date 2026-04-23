import '../constants/app_config.dart';

/// Pure-Dart date utilities used by multiple features.
/// No Flutter imports – this belongs to the domain/data layer.
class DateHelpers {
  DateHelpers._();

  /// Number of full days since the relationship started.
  static int daysTogether([DateTime? now]) {
    final today = now ?? DateTime.now();
    return today.difference(AppConfig.relationshipStart).inDays;
  }

  /// Returns a detailed string of time together: e.g. "4 years 2 months 1 day"
  /// Only includes non-zero values.
  static String detailedDurationTogether([DateTime? now]) {
    final today = now ?? DateTime.now();
    final start = AppConfig.relationshipStart;

    int years = today.year - start.year;
    int months = today.month - start.month;
    int days = today.day - start.day;

    if (days < 0) {
      months--;
      // Get the number of days in the previous month
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    int weeks = days ~/ 7;
    days = days % 7;

    final parts = <String>[];
    if (years > 0) parts.add('$years year${years == 1 ? '' : 's'}');
    if (months > 0) parts.add('$months month${months == 1 ? '' : 's'}');
    if (weeks > 0) parts.add('$weeks week${weeks == 1 ? '' : 's'}');
    if (days > 0) parts.add('$days day${days == 1 ? '' : 's'}');

    if (parts.isEmpty) return '0 days';
    return parts.join(' ');
  }

  /// Whether today matches the anniversary date (month + day).
  static bool isAnniversaryToday([DateTime? now]) {
    final today = now ?? DateTime.now();
    return today.month == AppConfig.anniversaryMonth &&
        today.day == AppConfig.anniversaryDay;
  }

  /// Whether today is Valentine's Day.
  static bool isValentinesDay([DateTime? now]) {
    final today = now ?? DateTime.now();
    return today.month == AppConfig.valentinesMonth &&
        today.day == AppConfig.valentinesDay;
  }

  /// Number of calendar years the couple has been together.
  static int yearsTogether([DateTime? now]) {
    final today = now ?? DateTime.now();
    int years = today.year - AppConfig.relationshipStart.year;
    final anniversaryThisYear = DateTime(
      today.year,
      AppConfig.anniversaryMonth,
      AppConfig.anniversaryDay,
    );
    if (today.isBefore(anniversaryThisYear)) years--;
    return years;
  }

  /// Returns a human-readable relative string like "2 years ago today"
  /// or "1 year ago" for a given event date compared to [now].
  static String relativeTimeText(DateTime eventDate, [DateTime? now]) {
    final today = now ?? DateTime.now();
    final years = today.year - eventDate.year;
    final months = today.month - eventDate.month;

    if (years > 0 && _isMonthDayMatch(eventDate, today)) {
      return '$years ${years == 1 ? 'year' : 'years'} ago today';
    }
    if (years > 0) {
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
    if (months > 0) {
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
    final days = today.difference(eventDate).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  /// Check if a timeline date string matches today's month and day.
  /// Handles formats: "2022-02-05", "2022-03", "2024-07/08".
  static bool matchesMonthDay(String? dateStr, [DateTime? now]) {
    if (dateStr == null || dateStr.isEmpty) return false;
    final today = now ?? DateTime.now();
    final todayMonth = today.month;
    final todayDay = today.day;

    // Handle "YYYY-MM/MM" range format (e.g. "2024-07/08")
    final rangeMatch = RegExp(r'^(\d{4})-(\d{1,2})/(\d{1,2})$').firstMatch(dateStr);
    if (rangeMatch != null) {
      final startMonth = int.parse(rangeMatch.group(2)!);
      final endMonth = int.parse(rangeMatch.group(3)!);
      return todayMonth >= startMonth && todayMonth <= endMonth;
    }

    // Handle "YYYY-MM-DD"
    final fullMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateStr);
    if (fullMatch != null) {
      final month = int.parse(fullMatch.group(2)!);
      final day = int.parse(fullMatch.group(3)!);
      return todayMonth == month && todayDay == day;
    }

    // Handle "YYYY-MM"
    final monthMatch = RegExp(r'^(\d{4})-(\d{1,2})$').firstMatch(dateStr);
    if (monthMatch != null) {
      final month = int.parse(monthMatch.group(2)!);
      return todayMonth == month;
    }

    return false;
  }

  /// Parse a timeline date string to a best-effort DateTime.
  /// Returns null if unparseable.
  static DateTime? parseTimelineDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    // "YYYY-MM-DD"
    final fullMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateStr);
    if (fullMatch != null) {
      return DateTime(
        int.parse(fullMatch.group(1)!),
        int.parse(fullMatch.group(2)!),
        int.parse(fullMatch.group(3)!),
      );
    }

    // "YYYY-MM/MM" → use start month, day 1
    final rangeMatch = RegExp(r'^(\d{4})-(\d{1,2})/(\d{1,2})$').firstMatch(dateStr);
    if (rangeMatch != null) {
      return DateTime(
        int.parse(rangeMatch.group(1)!),
        int.parse(rangeMatch.group(2)!),
      );
    }

    // "YYYY-MM" → day 1
    final monthMatch = RegExp(r'^(\d{4})-(\d{1,2})$').firstMatch(dateStr);
    if (monthMatch != null) {
      return DateTime(
        int.parse(monthMatch.group(1)!),
        int.parse(monthMatch.group(2)!),
      );
    }

    return null;
  }

  /// Deterministic "daily pick" index that changes once per day.
  /// Used for Featured Memory rotation without randomness.
  static int dailyPickIndex(int itemCount, [DateTime? now]) {
    if (itemCount <= 0) return 0;
    final today = now ?? DateTime.now();
    // Simple hash based on day-of-year
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    return (dayOfYear * 31 + today.year * 7) % itemCount;
  }

  static bool _isMonthDayMatch(DateTime a, DateTime b) {
    return a.month == b.month && a.day == b.day;
  }
}
