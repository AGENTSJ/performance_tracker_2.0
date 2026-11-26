import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/core/models/activity.model.dart';
import 'package:performance_tracker/core/models/day.model.dart';
import 'package:performance_tracker/core/models/food.model.dart';
import 'package:performance_tracker/core/models/user.model.dart';
import 'package:performance_tracker/core/repositories/day.repository.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/core/services/userGoals.service.dart';

class DayService {
  final _dayRepo = locator<DayRepository>();
  final goalService = locator<UserGoalsService>();
  final _commonService = locator<CommonService>();

  /// Returns the stored day for [date], or a new unsaved one.
  Future<Day?> getDayDataByDate(DateTime date) async {
    var day = _dayRepo.getDayByDateKey(_commonService.getDateKey(date));
    if (day != null) {
      return day;
    }
    Day? newDay = Day(dayTime: date);
    // In-memory default only: saved with the day once a food is added.
    newDay.activity = Activity(steps: 0);
    return newDay;
  }

  /// Maintenance calories for [day], recalculated from [user], the day's food
  /// and the steps stored on the day.
  double getMaintenanceCalories(Day day, User user) {
    return goalService.fetchMaintenanceCalories(
      user,
      getDaysCalories(day),
      steps: day.activity?.steps ?? 0,
    );
  }

  /// Saves [day] under its DATE_KEY. A day reaches storage only once one of
  /// its meals has a food; after that every update is saved, even if all the
  /// foods are removed again.
  updateDayData(Day day) async {
    final dateKey = _commonService.getDateKey(day.dayTime);
    if (!_dayRepo.isDayStored(dateKey) && !hasFood(day)) {
      return;
    }
    await _dayRepo.updateDayData(day);
  }

  bool hasFood(Day day) {
    return (day.meals ?? []).any((meal) => meal.foods.isNotEmpty);
  }

  Day? getDayByDateKey(String dateKey) {
    return _dayRepo.getDayByDateKey(dateKey);
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
 
  List<Day> getAllDays()
  {
    return _dayRepo.getAllDays();
  }

  Future<Day?> addDay(Day day)
  {
    return _dayRepo.addDayData(day);
  }

  clearAllDays()async
  {
    await _dayRepo.clearAllDays();
  }
}
