import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/repositories/food.repository.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/day.service.dart';
// import 'package:performance_tracker/services/nutritionInfoProvide.service.dart';

class FoodService {
  final _ai = locator<AiService>();
  final _foodRepo = locator<FoodRepository>();
  // final nutriApi = locator<NutritionServiceProvider>();
  final dayService = locator<DayService>();

  Future<List<Food>> searchFood(String key) async {
    var foods = _foodRepo.searchFoodByName(key);
    // var foodsFromApi = await nutriApi.getFoodByNameAPI(key);
    return foods;
  }

  List<Food> getAllFoods() {
    return _foodRepo.getAllFoods();
  }

  Future<List<Food>> suggestFoods(Meal meal, Day day) async {
    var currentDay = day;
    const contextLimitInDays = 5;
    Set<String> selectedFoodNames = {};
    List<Food> selectedFoods = [];

    for (var i = 1; i <= contextLimitInDays; i++) {
      var date = currentDay.dayTime.subtract(Duration(days: i));
      var dayObject = await dayService.getDayDataByDate(date);

      for (var currDayMeal in dayObject!.meals!) {
        if (currDayMeal.mealName == meal.mealName) {
          for (var food in currDayMeal.foods) {
            if (!selectedFoodNames.contains(food.name)) {
              selectedFoodNames.add(food.name);
              selectedFoods.add(food);
            }
          }
        }
      }
    }
    if (selectedFoods.isEmpty) {
      selectedFoods = getAllFoods();
    }
    return selectedFoods;
  }

  addFood(Food food) {
    _foodRepo.addFood(food);
  }
  removeFood(Food food) async
  {
    await _foodRepo.removeFood(food);
  }
  bool foodExist(String name) {
    return _foodRepo.foodExist(name);
  }

  Future<Food?> AI_CreateFood(String name, String? description) async {
    try {
      const String jsonResponseStructure = '''
      {
        "name":"String",
        "macro":{
          "protein":double value,
          "fat":double value,
          "carbohydrate":double value,
          "fiber":double value,
          "calories":double value
        },
        "micro":{
          "Vitamin A":{
            "value":Double value,
            "unit":"mcg"
            },
            "Vitamin C": {
            "value": Double value,
            "unit": "mg"
            },
            "Vitamin D": {
            "value": Double value,
            "unit": "mcg"
            },
            "Vitamin E": {
            "value": Double value,
            "unit": "mg"
            },
            "Vitamin K": {
            "value": Double value,
            "unit": "mcg"
            },
            "Thiamin": {
            "value": Double value,
            "unit": "mg"
            },
            "Riboflavin": {
            "value": Double value,
            "unit": "mg"
            },
            "Niacin": {
            "value": Double value,
            "unit": "mg"
            },
            "Vitamin B6": {
            "value": Double value,
            "unit": "mg"
            },
            "Folate": {
            "value": Double value,
            "unit": "mcg"
            },
            "Vitamin B12": {
            "value": Double value,
            "unit": "mcg"
            },
            "Pantothenic Acid": {
            "value": Double value,
            "unit": "mg"
            },
            "Biotin": {
            "value": Double value,
            "unit": "mcg"
            },
            "Calcium": {
            "value": Double value,
            "unit": "mg"
            },
            "Iron": {
            "value": Double value,
            "unit": "mg"
            },
            "Magnesium": {
            "value": Double value,
            "unit": "mg"
            },
            "Phosphorus": {
            "value": Double value,
            "unit": "mg"
            },
            "Potassium": {
            "value": Double value,
            "unit": "mg"
            },
            "Sodium": {
            "value": Double value,
            "unit": "mg"
            },
            "Zinc": {
            "value": Double value,
            "unit": "mg"
            },
            "Copper": {
            "value": Double value,
            "unit": "mg"
            },
            "Manganese": {
            "value": Double value,
            "unit": "mg"
            },
            "Selenium": {
            "value": Double value,
            "unit": "mcg"
            },
            "Iodine": {
            "value": Double value,
            "unit": "mcg"
            },
            "Chromium": {
            "value": Double value,
            "unit": "mcg"
            },
            "Molybdenum": {
            "value": Double value,
            "unit": "mcg"
            },
            "Fluoride": {
            "value": Double value,
            "unit": "mcg"
            },
            "Chloride": {
            "value": Double value,
            "unit": "mg"
            }
        }
        "servings":[
          {
            "unit":"common serving or 'serving'",
            "value":double value in grams
          },
        ]
      }
      ''';

      String prompt =
          "food name  $name , description:$description , Do not include any code block markers (such as json) in your response, as this will interfere with parsing.";
      // const String instructions = "You are a food data generator. Return the macro nutrients in JSON format for 100 grams of the specified food, using the structure provided in $jsonResponseStructure. The unit is not required, as all values are in grams, and all fields should be of type double. Use the food name and description, if available, to make the best estimation.Your response must include only the macro nutrients in the given JSON format, with no extra text or decorations. Do not include any code block markers (such as json) in your response, as this will interfere with parsing. if the name of the food doesn't make sense you can return the text error without json";
      const String instructions =
      '''
      You are a food macro and micro nutrient predicting API End point
      your responsibilities :
        1. Predict the foods macro and micro nutrients based on user input food name and description.
        2. Provide your prediction in the provided format.
      Note :
        1 Your response should be in json.
        2 SHOULD NOT INCLUDE  ```json ```or any other code blocker.
        3 Food macro and micros should be based on 100 grams. 
        4 adhere to the response format strictly.
        5 put your knowledge here to the best use if not known make a guess based on user description.
        6 If even the description doesn't make sense return text error without json format.
      Format :
        $jsonResponseStructure
      ''';

      var body = await _ai.getResponse(prompt, instructions,modelType: Models.Flash);
      var resString = body.message;
      if(resString[0]=="`")
      {
        resString = resString.substring(7, resString.length - 3);
      }
      var json = jsonDecode(resString);

      // Parse macros
      final macroJson = json['macro'];
      final macros = MacroNutrients(
        (macroJson['protein'] as num).toDouble(),
        (macroJson['carbohydrate'] as num).toDouble(),
        (macroJson['fat'] as num).toDouble(),
        (macroJson['fiber'] as num).toDouble(),
        (macroJson['calories'] as num).toDouble(),
      );

      // Parse micros
      final microJson = json['micro'] as Map<String, dynamic>;
      final microNutrients = MicroNutrients(
        vitaminA: _getUnit(microJson, 'Vitamin A'),
        vitaminC: _getUnit(microJson, 'Vitamin C'),
        vitaminD: _getUnit(microJson, 'Vitamin D'),
        vitaminE: _getUnit(microJson, 'Vitamin E'),
        vitaminK: _getUnit(microJson, 'Vitamin K'),
        thiamin: _getUnit(microJson, 'Thiamin'),
        riboflavin: _getUnit(microJson, 'Riboflavin'),
        niacin: _getUnit(microJson, 'Niacin'),
        vitaminB6: _getUnit(microJson, 'Vitamin B6'),
        folate: _getUnit(microJson, 'Folate'),
        vitaminB12: _getUnit(microJson, 'Vitamin B12'),
        pantothenicAcid: _getUnit(microJson, 'Pantothenic Acid'),
        biotin: _getUnit(microJson, 'Biotin'),
        calcium: _getUnit(microJson, 'Calcium'),
        iron: _getUnit(microJson, 'Iron'),
        magnesium: _getUnit(microJson, 'Magnesium'),
        phosphorus: _getUnit(microJson, 'Phosphorus'),
        potassium: _getUnit(microJson, 'Potassium'),
        sodium: _getUnit(microJson, 'Sodium'),
        zinc: _getUnit(microJson, 'Zinc'),
        copper: _getUnit(microJson, 'Copper'),
        manganese: _getUnit(microJson, 'Manganese'),
        selenium: _getUnit(microJson, 'Selenium'),
        iodine: _getUnit(microJson, 'Iodine'),
        chromium: _getUnit(microJson, 'Chromium'),
        molybdenum: _getUnit(microJson, 'Molybdenum'),
        fluoride: _getUnit(microJson, 'Fluoride'),
        chloride: _getUnit(microJson, 'Chloride'),
      );
      final servings = (json['servings'] as List<dynamic>)
          .map(
            (e) => MeasuredUnit(
              value: (e['value'] as num).toDouble(),
              unit: e['unit'],
            ),
          )
          .toList();
      var food = Food(
        name: json['name'],
        macros: macros,
        micros: microNutrients,
        quantity: MeasuredUnit(value: 100, unit: 'g'), // assuming the first is default quantity
        servings: servings,
        imageUrl: null, // JSON doesn't include imageUrl
      );
      addFood(food);
      return food;
    } catch (e) {
      return null;
    }
  }

  MeasuredUnit? _getUnit(Map<String, dynamic> json, String key) {
    final data = json[key];
    if (data == null) return null;
    return MeasuredUnit(
      value: (data['value'] as num).toDouble(),
      unit: data['unit'],
    );
  }

  clearAllFood()async
  {
    _foodRepo.clearAllFoodData();
  }
}
