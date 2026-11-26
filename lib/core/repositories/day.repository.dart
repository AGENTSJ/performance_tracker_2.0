import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/core/models/day.model.dart';
import 'package:performance_tracker/core/services/common.service.dart';

/// Days are stored with their DATE_KEY (`yyyy-MM-dd`) as the Hive key.
class DayRepository
{
  final _dayBox = Hive.box<Day>(Collections.days.value);
  final _commonService = locator<CommonService>();

  String _keyOf(Day day) => _commonService.getDateKey(day.dayTime);

  Future<Day?> addDayData(Day day) async
  {
    var key = _keyOf(day);
    await _dayBox.put(key, day);
    return _dayBox.get(key);
  }

  Day? getDayData(DateTime dayTime)
  {
    return getDayByDateKey(_commonService.getDateKey(dayTime));
  }

  Day? getDayByDateKey(String dateKey)
  {
    return _dayBox.get(dateKey);
  }

  bool isDayStored(String dateKey)
  {
    return _dayBox.containsKey(dateKey);
  }

  Future<void> updateDayData(Day day) async
  {
    await _dayBox.put(_keyOf(day), day);
  }

  List<Day> getAllDays()
  {
    return _dayBox.values.toList();
  }

  clearAllDays()async
  {
    await _dayBox.clear();
  }
}
