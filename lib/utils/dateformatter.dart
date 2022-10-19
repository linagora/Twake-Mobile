import 'package:intl/intl.dart';

class DateFormatter {
  /// Function to get a verbose representation of timestamp,
  /// like [just now] or [today]
  static String getVerboseDateTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final localDT = dateTime.toLocal();
    // if timestamp is less than a minute old return 'Now'
    DateTime justNow = DateTime.now();
    if (justNow.difference(localDT).abs() < Duration(minutes: 1)) {
      return 'Now';
    }

    // if the date is the same return time without seconds, taking
    // locale into account
    String approximateTime = DateFormat('HH:mm').format(localDT);
    if (localDT.year == justNow.year &&
        localDT.month == justNow.month &&
        localDT.day == justNow.day) {
      return approximateTime;
    }

    // include year in date if message is from previous year
    if (justNow.difference(localDT) > Duration(days: 365)) {
      return '${DateFormat('d MMM y HH:mm').format(localDT)}';
    }

    return '${DateFormat('d MMM HH:mm').format(localDT)}';
  }

  static String getVerboseDate(int timestamp, [bool lowercase = false]) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    DateTime justNow = DateTime.now().subtract(Duration(minutes: 1));
    if (!dateTime.difference(justNow).isNegative) {
      return lowercase ? 'now' : 'Now';
    }
    DateTime yesterday = justNow.subtract(Duration(days: 1));
    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return lowercase ? 'yesterday' : 'Yesterday';
    }
    if (dateTime.year == justNow.year &&
        dateTime.month == justNow.month &&
        dateTime.day == justNow.day) {
      return lowercase ? 'today' : 'Today';
    }
    return '${DateFormat('d MMM y').format(dateTime)}';
  }

  // Return just time
  static String getVerboseTime(int timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    return '${DateFormat('HH:mm').format(dateTime)}';
  }

  static String getVerboseTimeForHomeTile(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final localDT = dateTime.toLocal();

    // if timestamp is less than a minute old return 'Now'
    DateTime justNow = DateTime.now();
    if (justNow.difference(localDT).abs() < Duration(minutes: 1)) {
      return 'Now';
    }

    if (localDT.year == justNow.year) {
      if (localDT.month == justNow.month) {
        final firstDateOfWeek = _findFirstDateOfTheWeek(justNow);

        if (localDT.day == justNow.day) {
          // today
          return DateFormat('HH:mm').format(localDT);
        } else if (localDT.day > firstDateOfWeek.day) {
          // display this week date name
          return DateFormat('EEE').format(localDT);
        } else {
          // not this month
          return '${DateFormat('d MMM').format(localDT)}';
        }
      } else {
        // not this month
        return '${DateFormat('d MMM').format(localDT)}';
      }
    }

    // not this year
    return '${DateFormat('d.MM.yy').format(localDT)}';
  }

  static DateTime _findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }
}
// TODO localize everything
