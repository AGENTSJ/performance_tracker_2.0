import 'package:performance_tracker/core/models/day.model.dart';

class CommonService {
  double getPercentage(double total, double part) {
    if (total == 0) {
      return 0;
    }
    return (part / total) * 100;
  }

  String getDateString(DateTime date) {
    var year = date.year;
    var month = date.month;
    var dayOfMonth = date.day;
    return "$dayOfMonth ${Months.values[month - 1].name} $year";
  }

  /// DATE_KEY: the date without its time, as `yyyy-MM-dd`.
  /// Uses today when no [date] is given. Zero-padded so keys sort chronologically.
  String getDateKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "${d.year}-$month-$day";
  }

  String getTimeString(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
