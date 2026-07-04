extension DateTimeExtensions on DateTime {
  /// Returns true if this date is the same calendar day as [other]
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Returns a DateTime representing the start of this day (midnight)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns a DateTime representing the end of this day (23:59:59.999)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns true if this date is today
  bool get isToday => isSameDay(DateTime.now());

  /// Returns true if this date is yesterday
  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Returns 'Today', 'Yesterday', or formatted date
  String get relativeLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return '${_monthName(month)} $day';
  }

  /// Returns a short time string like '2:30 PM'
  String get timeLabel {
    final hour = this.hour;
    final minute = this.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
