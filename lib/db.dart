import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/modules/nutritionModule/models/day.model.dart';
import 'package:performance_tracker/modules/nutritionModule/models/food.model.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';

enum Collections
{
  foods('foodCollection'),
  days('daysCollection'),
  users('usersCollection');
  
  final String value;
  const Collections(this.value);
}

Future<void> setupHiveDb() async
{
  await Hive.initFlutter();

  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(MacroNutrientsAdapter());
  Hive.registerAdapter(MicroNutrientsAdapter());
  Hive.registerAdapter(MeasuredUnitAdapter());
  Hive.registerAdapter(DayAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(DayCommentsAdapter());
  Hive.registerAdapter(GeneratedCommentAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(UserGoalsAdapter());
  Hive.registerAdapter(GenderAdapter());
  Hive.registerAdapter(ActivityLevelAdapter());
  await Hive.openBox<Food>(Collections.foods.value);
  await Hive.openBox<Day>(Collections.days.value);
  await Hive.openBox<User>(Collections.users.value);
  // await Hive.deleteBoxFromDisk(Collections.foods.value);
  // await Hive.deleteBoxFromDisk(Collections.days.value);
}