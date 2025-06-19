import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/repository/day.repository.dart';

class DayService
{
  final _dayRepo = locator<DayRepository>();
 
  Future<Day?> getDayDataByDate(DateTime date) async
  {
    var day =  _dayRepo.getDayData(date);
    if(day!=null)
    {
      return day;
    }
    Day? newDay = Day(dayTime: date);
    newDay = await _dayRepo.addDayData(newDay);    
    return newDay;
  }

  updateDayData(Day day) async
  {
    await _dayRepo.updateDayData(day);
  }

  String getDateString(DateTime date)
  {
    var year = date.year;
    var month = date.month;
    var dayOfMonth = date.day;
    return "$dayOfMonth ${Months.values[month-1].name.substring(0,3)} $year"; 
  }
}