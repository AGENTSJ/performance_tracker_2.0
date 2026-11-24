import 'package:hive/hive.dart';
import 'package:performance_tracker/core/models/activity.model.dart';
import 'package:performance_tracker/core/models/food.model.dart';

part 'generated/day.model.g.dart';

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

  @HiveField(5)
  late Meal eveningSnacks;

  @HiveField(6)
  List<Meal>? meals;

  @HiveField(7)
  DateTime dayTime;

  @HiveField(8)
  DayComments? comments;

  // HiveField 9 was `goalForToday` (removed in Phase 3: goals are periods in
  // the userGoals box). Don't reuse index 9.
  
  /// Legacy: no longer read or written. A day's routine is now found by its
  /// DATE_KEY in the routine box.
  @HiveField(10)
  int? routineId;
  
  @HiveField(11)
  Activity? activity;

  
  Day({required this.dayTime}) {
    breakFast = Meal(mealName: 'Breakfast', foods: []);
    morningSnacks = Meal(mealName: 'Morning Snacks', foods: []);
    lunch = Meal(mealName: 'Lunch', foods: []);
    eveningSnacks = Meal(mealName: 'Evening Snacks', foods: []);
    dinner = Meal(mealName: 'Dinner', foods: []);
    meals = [breakFast,morningSnacks, lunch,eveningSnacks ,dinner];
  }

  Map<String, dynamic> toJson() => {
    'breakFast': breakFast.toJson(),
    'lunch': lunch.toJson(),
    'morningSnacks': morningSnacks.toJson(),
    'dinner': dinner.toJson(),
    'eveningSnacks': eveningSnacks.toJson(),
    'meals': meals?.map((meal) => meal.toJson()).toList(),
    'dayTime': dayTime.toIso8601String(),
    'comments': comments?.toJson(),
    'routineId': routineId,
    'activity': activity?.toJson(),
  };

  factory Day.fromJson(Map<String, dynamic> json) {
    Day day = Day(dayTime: DateTime.parse(json['dayTime'] as String));
    day.breakFast = Meal.fromJson(json['breakFast'] as Map<String, dynamic>);
    day.lunch = Meal.fromJson(json['lunch'] as Map<String, dynamic>);
    day.morningSnacks = Meal.fromJson(json['morningSnacks'] as Map<String, dynamic>);
    day.dinner = Meal.fromJson(json['dinner'] as Map<String, dynamic>);
    day.eveningSnacks = Meal.fromJson(json['eveningSnacks'] as Map<String, dynamic>);
    day.meals = (json['meals'] as List<dynamic>?)
        ?.map((mealJson) => Meal.fromJson(mealJson as Map<String, dynamic>))
        .toList();
    day.comments = json['comments'] != null 
        ? DayComments.fromJson(json['comments'] as Map<String, dynamic>)
        : null;
    day.routineId = json['routineId'] as int?;
    day.activity = json['activity'] != null
        ? Activity.fromJson(json['activity'] as Map<String, dynamic>)
        : null;
    return day;
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

  Map<String, dynamic> toJson() => {
    'mealName': mealName,
    'foods': foods.map((food) => food.toJson()).toList(),
    'calories': calories,
  };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    mealName: json['mealName'] as String,
    foods: (json['foods'] as List<dynamic>)
        .map((foodJson) => Food.fromJson(foodJson as Map<String, dynamic>))
        .toList(),
    calories: json['calories'] as double?,
  );
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

@HiveType(typeId: 7)
class DayComments extends HiveObject {
  @HiveField(0)
  GeneratedComment? macroNutrientsComments;

  @HiveField(1)
  GeneratedComment? microNutrientsComments;

  @HiveField(2)
  GeneratedComment? overallDietComments;

  DayComments({
    this.macroNutrientsComments,
    this.microNutrientsComments,
    this.overallDietComments,
  });

  Map<String, dynamic> toJson() => {
    'macroNutrientsComments': macroNutrientsComments?.toJson(),
    'microNutrientsComments': microNutrientsComments?.toJson(),
    'overallDietComments': overallDietComments?.toJson(),
  };

  factory DayComments.fromJson(Map<String, dynamic> json) => DayComments(
    macroNutrientsComments: json['macroNutrientsComments'] != null
        ? GeneratedComment.fromJson(json['macroNutrientsComments'] as Map<String, dynamic>)
        : null,
    microNutrientsComments: json['microNutrientsComments'] != null
        ? GeneratedComment.fromJson(json['microNutrientsComments'] as Map<String, dynamic>)
        : null,
    overallDietComments: json['overallDietComments'] != null
        ? GeneratedComment.fromJson(json['overallDietComments'] as Map<String, dynamic>)
        : null,
  );
}

@HiveType(typeId: 8)
class GeneratedComment extends HiveObject {
  @HiveField(0)
  String comment;

  @HiveField(1)
  DateTime timeOfGeneration;

  @HiveField(2)
  MacroNutrients macrosAtGenTime;

  GeneratedComment({
    required this.comment,
    required this.timeOfGeneration,
    required this.macrosAtGenTime,
  });

  Map<String, dynamic> toJson() => {
    'comment': comment,
    'timeOfGeneration': timeOfGeneration.toIso8601String(),
    'macrosAtGenTime': macrosAtGenTime.toJson(),
  };

  factory GeneratedComment.fromJson(Map<String, dynamic> json) => GeneratedComment(
    comment: json['comment'] as String,
    timeOfGeneration: DateTime.parse(json['timeOfGeneration'] as String),
    macrosAtGenTime: MacroNutrients.fromJson(json['macrosAtGenTime'] as Map<String, dynamic>),
  );
}
