class Food {
  final String? name;
  final MacroNutrients macros;
  final MicroNutrients micros;
  final MeasuredUnit quantity;

  Food({
    this.name,
    required this.macros,
    required this.micros,
    required this.quantity,
  });
}

class MacroNutrients {
  double protein;
  double fat;
  double carbohydrate;
  double fiber;
  late double calories;
  MacroNutrients(
    this.protein,
    this.carbohydrate,
    this.fat,
    this.fiber,
    double calories,
  ) {

    this.calories = protein*4+carbohydrate*4+fat*9;
  }
}

class MicroNutrients {
  MeasuredUnit? vitaminA;
  MeasuredUnit? vitaminC;
  MeasuredUnit? vitaminD;
  MeasuredUnit? vitaminE;
  MeasuredUnit? vitaminK;
  MeasuredUnit? thiamin; // Vitamin B1
  MeasuredUnit? riboflavin; // Vitamin B2
  MeasuredUnit? niacin; // Vitamin B3
  MeasuredUnit? vitaminB6;
  MeasuredUnit? folate; // Vitamin B9
  MeasuredUnit? vitaminB12;
  MeasuredUnit? pantothenicAcid; // Vitamin B5
  MeasuredUnit? biotin; // Vitamin B7

  MeasuredUnit? calcium;
  MeasuredUnit? iron;
  MeasuredUnit? magnesium;
  MeasuredUnit? phosphorus;
  MeasuredUnit? potassium;
  MeasuredUnit? sodium;
  MeasuredUnit? zinc;
  MeasuredUnit? copper;
  MeasuredUnit? manganese;
  MeasuredUnit? selenium;
  MeasuredUnit? iodine;
  MeasuredUnit? chromium;
  MeasuredUnit? molybdenum;
  MeasuredUnit? fluoride;
  MeasuredUnit? chloride;
  late Map<String,MeasuredUnit?> microMap;
  
  MicroNutrients({
    this.vitaminA,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
    this.vitaminK,
    this.thiamin,
    this.riboflavin,
    this.niacin,
    this.vitaminB6,
    this.folate,
    this.vitaminB12,
    this.pantothenicAcid,
    this.biotin,
    this.calcium,
    this.iron,
    this.magnesium,
    this.phosphorus,
    this.potassium,
    this.sodium,
    this.zinc,
    this.copper,
    this.manganese,
    this.selenium,
    this.iodine,
    this.chromium,
    this.molybdenum,
    this.fluoride,
    this.chloride,
  }) : microMap = {
    'Vitamin A': vitaminA,
    'Vitamin C': vitaminC,
    'Vitamin D': vitaminD,
    'Vitamin E': vitaminE,
    'Vitamin K': vitaminK,
    'Thiamin': thiamin,
    'Riboflavin': riboflavin,
    'Niacin': niacin,
    'Vitamin B6': vitaminB6,
    'Folate': folate,
    'Vitamin B12': vitaminB12,
    'Pantothenic Acid': pantothenicAcid,
    'Biotin': biotin,
    'Calcium': calcium,
    'Iron': iron,
    'Magnesium': magnesium,
    'Phosphorus': phosphorus,
    'Potassium': potassium,
    'Sodium': sodium,
    'Zinc': zinc,
    'Copper': copper,
    'Manganese': manganese,
    'Selenium': selenium,
    'Iodine': iodine,
    'Chromium': chromium,
    'Molybdenum': molybdenum,
    'Fluoride': fluoride,
    'Chloride': chloride,
  };
}

class MeasuredUnit {
  double value;
  String unit;
  MeasuredUnit({required this.value, required this.unit});
}
