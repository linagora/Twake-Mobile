import 'package:intl/intl.dart';

class DateFormatter {
  /// Function to get a verbose representation of timestamp,
  /// like [just now] or [today]
  static String getVerboseDateTime(int timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final localDT = dateTime.toLocal();
    // if timestamp is less than a minute old return 'Now'
    DateTime justNow = DateTime.now();
    if (justNow.difference(localDT).abs() < Duration(minutes: 1)) {
      return 'Now';
    }

    // if the date is the same return time without seconds, taking
    // locale into account
    String approximateTime = DateFormat('HH:mm').format(dateTime);
    if (localDT.year == justNow.year &&
        localDT.month == justNow.month &&
        localDT.day == justNow.day) {
      return approximateTime;
    }

    // include year in date if message is from previous year
    if (justNow.difference(localDT) > Duration(days: 365)) {
      return '${DateFormat('d MMM y HH:mm').format(dateTime)}';
    }

    return '${DateFormat('d MMM HH:mm').format(dateTime)}';

    // by default return 'year/month/day, time'
  }

  static String getVerboseDate(int timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
    DateTime justNow = DateTime.now().subtract(Duration(minutes: 1));
    if (!dateTime.difference(justNow).isNegative) {
      return 'Now';
    }
    DateTime yesterday = justNow.subtract(Duration(days: 1));
    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday';
    }
    if (dateTime.year == justNow.year &&
        dateTime.month == justNow.month &&
        dateTime.day == justNow.day) {
      return 'Today';
    }
    return '${DateFormat('d MMM y').format(dateTime)}';
  }

  // Return just time
  static String getVerboseTime(int timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
    return '${DateFormat('HH:mm').format(dateTime)}';
  }
}
// TODO localize everything
