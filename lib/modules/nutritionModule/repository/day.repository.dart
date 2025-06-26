import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/modules/nutritionModule/models/day.model.dart';

class DayRepository 
{
  final _dayBox = Hive.box<Day>(Collections.days.value);
  
  Future<Day?>addDayData(Day day) async
  {
    var key = await _dayBox.add(day);
    var insertedDay = _dayBox.getAt(key);
    return insertedDay;  
  }

  Day? getDayData(DateTime dayTime)
  {
    var days = _dayBox.values.toList();
    Day? foundDay;

    for (var day in days) 
    {
      var dayString1 = getDateString(day.dayTime);  
      var dayString2 = getDateString(dayTime);
      if(dayString2==dayString1)
      {
        foundDay = day;
        break;
      }  
    }    
    return foundDay;
  }
  
  Future<void>updateDayData(Day day) async
  {
    await _dayBox.put(day.key, day);
  }

  String getDateString(DateTime date)
  {
    var year = date.year;
    var month = date.month;
    var dayOfMonth = date.day;
    return "$year-$month-$dayOfMonth"; 
  }
  
}