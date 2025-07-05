import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/models/user.model.dart';

enum Collections
{
  foods('foodCollection'),
  days('daysCollection'),
  users('usersCollection'),
  routines('routines'),
  workouts('workouts');
  
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
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(RoutineAdapter());
  Hive.registerAdapter(SetAdapter());

  await Hive.openBox<Food>(Collections.foods.value);
  await Hive.openBox<Day>(Collections.days.value);
  await Hive.openBox<User>(Collections.users.value);
  await Hive.openBox<Routine>(Collections.routines.value);
  await Hive.openBox<Workout>(Collections.workouts.value);

  // await Hive.deleteBoxFromDisk(Collections.foods.value);
  // await Hive.deleteBoxFromDisk(Collections.days.value);
  // await Hive.deleteBoxFromDisk(Collections.users.value);
  // await Hive.deleteBoxFromDisk(Collections.routines.value);
  // await Hive.deleteBoxFromDisk(Collections.workouts.value);
}
_openBox<T>(String boxName)async
{
  try{
    await Hive.openBox<T>(boxName);
  }
  catch(e)
  {
    await Hive.deleteBoxFromDisk(boxName);
    await Hive.openBox<T>(boxName);
  }
}
