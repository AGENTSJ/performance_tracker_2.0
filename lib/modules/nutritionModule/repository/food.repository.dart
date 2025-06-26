import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/modules/nutritionModule/models/food.model.dart';
import 'package:performance_tracker/modules/nutritionModule/repository/foods.data.dart';

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
    var inpLowCaseFoodName = name.toLowerCase();

    for (var food in allFoods) {
      var currFoodNameInLowCase = food.name.toLowerCase();

      if(currFoodNameInLowCase.startsWith(inpLowCaseFoodName))
      {
        filtered.add(food);
        continue;
      }
    }
    return filtered;
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