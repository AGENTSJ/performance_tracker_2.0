import 'package:performance_tracker/data/foods.data.dart';
import 'package:performance_tracker/models/food.model.dart';

class FoodService
{
  var foods = availableFoods;

  List<Food> searchFood(String key)
  {
    List<Food>filteredFoods = []; 
    for (var food in foods) {
      if(food.name!.toLowerCase().startsWith(key.toLowerCase()))
      {
        filteredFoods.add(food);
      }
    }
    return filteredFoods;
  }

  List<Food> getAllFoods()
  {
    return foods;
  }
}