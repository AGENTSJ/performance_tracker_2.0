import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/core/models/food.model.dart';

class FoodRepository
{
  late final foodBox = Hive.box<Food>(Collections.foods.value);

  List<Food> getAllFoods()
  {
    List<Food> allFoods = foodBox.values.toList();
    return allFoods;
  }

  addFood(Food food)
  {
    foodBox.add(food);
  }
  removeFood(Food food) async
  {
    // Food isn't a HiveObject, so delete by key rather than .delete().
    final keysToDelete = foodBox.keys
        .where((key) => foodBox.get(key)?.name == food.name)
        .toList();
    await foodBox.deleteAll(keysToDelete);
  }
  List<Food> searchFoodByName(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return foodBox.values.toList();
    }

    final startsWith = <Food>[];
    final wordStartsWith = <Food>[];
    final contains = <Food>[];

    for (final food in foodBox.values) {
      final name = food.name.toLowerCase();

      // Exact prefix
      if (name.startsWith(q)) {
        startsWith.add(food);
        continue;
      }

      // Any word starts with query
      if (name.split(RegExp(r'\s+')).any((word) => word.startsWith(q))) {
        wordStartsWith.add(food);
        continue;
      }

      // Anywhere in the string
      if (name.contains(q)) {
        contains.add(food);
      }
    }

    return [
      ...startsWith,
      ...wordStartsWith,
      ...contains,
    ];
  }
  
  updateFood(Food food)
  {
    throw UnimplementedError();
  }

  bool foodExist(String name)
  {
    for (var food in foodBox.values) {
      if(food.name==name)
      {
        return true;
      }
    }
    return false;
  }

  void clearAllFoodData()async
  {
    await foodBox.clear();
  }
}