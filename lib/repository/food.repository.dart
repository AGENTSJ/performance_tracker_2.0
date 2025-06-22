import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/repository/foods.data.dart';

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

  List<Food> searchFoodByName(String name)
  {
    List<Food> allFoods = foodBox.values.toList();
    List<Food> filtered = [];
    for (var food in allFoods) {
      if(food.name.toLowerCase().startsWith(name.toLowerCase()))
      {
        filtered.add(food);
      }
    }
    return filtered;
  }
  
  updateFood(Food food)
  {
    throw UnimplementedError();
  }
  
  test()
  {
    var foods1 = getAllFoods();
    if(foods1.isEmpty)
    {
      var foods = availableFoods;
      for (var food in foods) {
        addFood(food);
      }
    }
  }
}