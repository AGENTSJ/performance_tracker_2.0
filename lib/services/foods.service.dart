import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/repository/food.repository.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/nutritionInfoProvide.service.dart';


class FoodService
{
  final _ai = locator<AiService>();
  final _foodRepo = locator<FoodRepository>();
  final nutriApi = locator<NutritionServiceProvider>();
  final dayService = locator<DayService>();
  
  Future<List<Food>> searchFood(String key) async
  {
    var foods = _foodRepo.searchFoodByName(key);
    if(foods.isEmpty)
    {
      foods = await nutriApi.getFoodByNameAPI(key);
      for (var food in foods) {
        _foodRepo.addFood(food);
      }
    }
    return foods;
  }

  List<Food> getAllFoods()
  {
    return _foodRepo.getAllFoods();
  }

  Future<List<Food>> suggestFoods(Meal meal ,Day day) async
  {
    var currentDay = day;
    const context_liit_in_days = 5;
    Set<String> selectedFoodNames = {};
    List<Food> selectedFoods = [];

    for (var i = 1 ;i<=context_liit_in_days;i++) {
      var date  = currentDay.dayTime.subtract(Duration(days: i));
      var dayObject = await dayService.getDayDataByDate(date);

      for(var currDayMeal in dayObject!.meals!)
      {
        if(currDayMeal.mealName == meal.mealName)
        {
          for (var food in currDayMeal.foods) {
            
            if(!selectedFoodNames.contains(food.name))
            {
              selectedFoodNames.add(food.name);
              selectedFoods.add(food);
            }
          }
        }
      }
    }
    if(selectedFoods.isEmpty)
    {
      selectedFoods = this.getAllFoods();
    }
    return selectedFoods;
  }

  addFoodToMeal(Food food)
  {
    _foodRepo.addFood(food); 
  }

  Future<Food?> AI_CreateFood(String name , String? description) async
  {
    try
    {
      const String jsonResponseStructure = '''
      {
        "protein":"double value",
        "fat":"double value",
        "carbohydrate":"double value",
        "fiber":"double value",
        "calories":"double value"
      }
      ''';
      String promt = "food name  $name , description:$description , Do not include any code block markers (such as json) in your response, as this will interfere with parsing.";
      const String instructions = "You are a food data generator. Return the macro nutrients in JSON format for 100 grams of the specified food, using the structure provided in $jsonResponseStructure. The unit is not required, as all values are in grams, and all fields should be of type double. Use the food name and description, if available, to make the best estimation.Your response must include only the macro nutrients in the given JSON format, with no extra text or decorations. Do not include any code block markers (such as json) in your response, as this will interfere with parsing. if the name of the food doesn't make sense you can return the text error without json";

      var body = await  _ai.getResponse(promt , instructions);
      var resString = body['candidates'][0]['content']['parts'][0]['text']; 
      var res = jsonDecode(resString);
      var prot = double.parse( res["protein"]);
      var carb = double.parse( res["carbohydrate"]);
      var fat = double.parse( res["fat"]);
      var fib = double.parse( res["fiber"]);
      var cal = double.parse( res["calories"]);
      var macro = MacroNutrients(prot,carb,fat,fib,cal);
      var food = Food(name: name,macros: macro, micros: MicroNutrients(), quantity: MeasuredUnit(unit: 'g',value: 100));
      addFoodToMeal(food);
      return food;
    }
    catch (e) {
      return null;
    }
  }
}
