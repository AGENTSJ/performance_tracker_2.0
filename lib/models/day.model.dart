import 'package:performance_tracker/models/food.model.dart';

class Day
{
  late Meal breakFast;
  late Meal lunch;
  late Meal dinner;
  List<Meal>? meals;
  Day()
  {
    breakFast = Meal(mealName: 'BreakFast', foods: []);
    lunch = Meal(mealName: 'Lunch', foods: []);
    dinner = Meal(mealName: 'Dinner', foods: []);
    meals = [breakFast,lunch,dinner];
  }
}

class Meal
{
  final String mealName;
  List<Food> foods;
  double? calories;

  Meal({required this.mealName,required this.foods});
}