import 'package:intl/intl.dart';

class DateFormatter {
  /// Function to get a verbose representation of timestamp,
  /// like [just now] or [today]
  static String getVerboseDateTime(int timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final localDT = dateTime.toLocal();
    // if timestamp is less than a minute old return 'Now'
    DateTime justNow = DateTime.now().subtract(Duration(minutes: 1));
    if (!localDT.difference(justNow).isNegative) {
      return 'Now';
    }

    // if the date is the same return time without seconds, taking
    // locale into account
    String approximateTime = DateFormat('jm').format(dateTime);
    if (localDT.year == justNow.year &&
        localDT.month == justNow.month &&
        localDT.day == justNow.day) {
      return approximateTime;
    }

    // if the date is one day before (less), return time prepended with
    // 'Yesterday'
    DateTime yesterday = justNow.subtract(Duration(days: 1));
    if (localDT.year == yesterday.year &&
        localDT.month == yesterday.month &&
        localDT.day == yesterday.day) {
      return 'Yesterday, ' + approximateTime;
    }

    // by default return 'year/month/day, time'
    return '${DateFormat('d MMMM y').format(dateTime)}';
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
    return '${DateFormat('d MMMM y').format(dateTime)}';
  }
}
// TODO localize everything
