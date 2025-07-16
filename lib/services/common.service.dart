import 'package:performance_tracker/models/day.model.dart';

class CommonService {

  double getPercentage(double total ,double part)
  {
    if(total==0)
    {
      return 0;
    }
    return (part / total)*100;
  }
  String getDateString(DateTime date)
  {
    var year = date.year;
    var month = date.month;
    var dayOfMonth = date.day;
    // return "$year-$month-$dayOfMonth"; 
    return "$dayOfMonth ${Months.values[month-1].name} $year";
  }
}