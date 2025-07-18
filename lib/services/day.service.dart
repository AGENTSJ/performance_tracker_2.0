import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/activity.model.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/repositories/day.repository.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';

class DayService {
  final _dayRepo = locator<DayRepository>();
  final goalService = locator<UserGoalsService>();
  final _routineService = locator<RoutineService>();
  final _commonService = locator<CommonService>();
  Future<Day?> getDayDataByDate(DateTime date) async {
    var day = _dayRepo.getDayData(date);
    if (day != null) {
      return day;
    }
    Day? newDay = Day(dayTime: date);
    var goal = await goalService.getUserGoals();
    newDay.goalForToday = goal;
    newDay.activity = Activity(steps: 0);
    var todaysRoutine = Routine(
      name: _commonService.getDateString(date),
      workoutsIds: [],
      createdAt: DateTime.now(),
      isCustom: false,
      desc: ''
    );
    int routId = await _routineService.addRoutine(todaysRoutine);

    newDay.routineId = routId;
    newDay = await _dayRepo.addDayData(newDay);
    return newDay;
  }

  updateDayData(Day day) async {
    await _dayRepo.updateDayData(day);
  }

  String getDateString(DateTime date) {
    var year = date.year;
    var month = date.month;
    var dayOfMonth = date.day;
    return "$dayOfMonth ${Months.values[month - 1].name.substring(0, 3)} $year";
  }

  MacroNutrients getDaysCalories(Day day) {
    var total = 0.0;
    var protein = 0.0;
    var fats = 0.0;
    var carbs = 0.0;
    var fiber = 0.0;
    for (var meal in day.meals!) {
      for (var food in meal.foods) {
        total += food.macros.calories;
        protein += food.macros.protein;
        fats += food.macros.fat;
        carbs += food.macros.carbohydrate;
        fiber += food.macros.fiber;
      }
    }
    MacroNutrients macrosForDay = MacroNutrients(
      protein,
      carbs,
      fats,
      fiber,
      total,
    );

    return macrosForDay;
  }
}
