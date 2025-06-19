import 'package:hive/hive.dart';
import 'package:performance_tracker/models/food.model.dart';

part 'day.model.g.dart';

@HiveType(typeId: 5)
class Day extends HiveObject {
  @HiveField(0)
  late Meal breakFast;

  @HiveField(1)
  late Meal lunch;

  @HiveField(2)
  late Meal morningSnacks;
  
  @HiveField(3)
  late Meal dinner;

  @HiveField(4)
  late Meal eveningSnacks;

  @HiveField(3)
  List<Meal>? meals;

  @HiveField(4)
  DateTime dayTime;

  Day({required this.dayTime}) {
    breakFast = Meal(mealName: 'Breakfast', foods: []);
    morningSnacks = Meal(mealName: 'Morning Snacks', foods: []);
    lunch = Meal(mealName: 'Lunch', foods: []);
    eveningSnacks = Meal(mealName: 'Evening Snacks', foods: []);
    dinner = Meal(mealName: 'Dinner', foods: []);
    meals = [breakFast, lunch, dinner];
  }
}

@HiveType(typeId: 6)
class Meal extends HiveObject {
  @HiveField(0)
  String mealName;

  @HiveField(1)
  List<Food> foods;

  @HiveField(2)
  double? calories;

  Meal({required this.mealName, required this.foods, this.calories});
}

enum Weekday {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday,
}

enum Months {
  January,
  February,
  March,
  April,
  May,
  June,
  July,
  August,
  September,
  October,
  November,
  December,
}