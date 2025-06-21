import 'dart:convert';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/rest.service.dart';

class NutritionServiceProvider {
  var restService = locator<RestService>();
  final String _api_key = '950de7964804f554959b558127663d61';
  final String _app_id = '8fd178f4';
  final String _provider_url =
      'https://trackapi.nutritionix.com/v2/natural/nutrients';
  var header;
  static final codeToNameUnit = {
    320: {"name": "Vitamin A", "unit": "mcg"},
    401: {"name": "Vitamin C", "unit": "mg"},
    328: {"name": "Vitamin D", "unit": "mcg"},
    323: {"name": "Vitamin E", "unit": "mg"},
    430: {"name": "Vitamin K", "unit": "mcg"},
    404: {"name": "Thiamin", "unit": "mg"},
    405: {"name": "Riboflavin", "unit": "mg"},
    406: {"name": "Niacin", "unit": "mg"},
    415: {"name": "Vitamin B6", "unit": "mg"},
    432: {"name": "Folate", "unit": "mcg"},
    418: {"name": "Vitamin B12", "unit": "mcg"},
    410: {"name": "Pantothenic Acid", "unit": "mg"},
    301: {"name": "Calcium", "unit": "mg"},
    303: {"name": "Iron", "unit": "mg"},
    304: {"name": "Magnesium", "unit": "mg"},
    305: {"name": "Phosphorus", "unit": "mg"},
    306: {"name": "Potassium", "unit": "mg"},
    307: {"name": "Sodium", "unit": "mg"},
    309: {"name": "Zinc", "unit": "mg"},
    312: {"name": "Copper", "unit": "mg"},
    315: {"name": "Manganese", "unit": "mg"},
    317: {"name": "Selenium", "unit": "mcg"},
    313: {"name": "Fluoride", "unit": "mcg"},
  };

  NutritionServiceProvider() {
    header = {
      'Content-Type': 'application/json',
      'x-app-id': _app_id,
      'x-app-key': _api_key,
    };
  }
  Future<List<Food>> getFoodByNameAPI(String foodName) async {
    var res = await restService.POST(_provider_url, {
      'query': foodName,
    }, headers: header);
    if (res.statusCode != 200) {
      return [];
    }
    var result = _getFoodObjectsFromResponse(res);
    return result;
  }

  List<Food> _getFoodObjectsFromResponse(response) {
    var foodsFromResponse = jsonDecode(response.body)["foods"];
    List<Food> result = [];
    for (var food in foodsFromResponse) {
      var foodName = food["food_name"];
      var nutrients = food["full_nutrients"];
      var quantity = MeasuredUnit(
        value: double.parse(food["serving_weight_grams"].toString()),
        unit: 'g',
      );
      var macros = MacroNutrients(
        double.parse(food["nf_protein"].toString()),
        double.parse(food["nf_total_carbohydrate"].toString()),
        double.parse(food["nf_total_fat"].toString()),
        double.parse(food["nf_dietary_fiber"].toString()),
        double.parse(food["nf_calories"].toString()),
      );
      Map<String, MeasuredUnit> microMap = {};

      for (var nutri in nutrients) {
        var code = nutri["attr_id"];
        var typeOfNutri = codeToNameUnit[code];
        if (typeOfNutri != null) {
          microMap[typeOfNutri["name"]!] = MeasuredUnit(
            value: double.parse(nutri["value"].toString()),
            unit: typeOfNutri["unit"]!,
          );
        }
      }
      var micros = MicroNutrients(
        vitaminA: microMap["Vitamin A"],
        vitaminC: microMap["Vitamin C"],
        vitaminD: microMap["Vitamin D"],
        vitaminE: microMap["Vitamin E"],
        vitaminK: microMap["Vitamin K"],
        calcium: microMap["Calcium"],
        iron: microMap["Iron"],
        potassium: microMap["Potassium"],
        sodium: microMap["Sodium"],
        copper: microMap["Copper"],
        fluoride: microMap["Fluoride"],
        folate: microMap["Folate"],
        magnesium: microMap["Magnesium"],
        manganese: microMap["Manganese"],
        niacin: microMap["Niacin"],
        phosphorus: microMap["Phosphorus"],
        riboflavin: microMap["Riboflavin"],
        selenium: microMap["Selenium"],
        thiamin: microMap["Thiamin"],
        zinc: microMap["Zinc"],
      );
      result.add(
        Food(
          name: foodName,
          macros: macros,
          micros: micros,
          quantity: quantity,
        ),
      );
    }
    return result;
  }
}
