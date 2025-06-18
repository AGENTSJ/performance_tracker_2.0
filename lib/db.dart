import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/models/food.model.dart';

enum Collections
{
  foods('foodCollection');
  
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
  await Hive.openBox<Food>(Collections.foods.value);
}