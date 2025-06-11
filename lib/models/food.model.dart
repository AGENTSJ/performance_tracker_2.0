class Food {
  final String? name;
  final MacroNutrients macros;
  final MicroNutrients micros;
  final MeasuredUnit baseUnit;
  const Food({
    this.name,
    required this.macros,
    required this.micros,
    required this.baseUnit,
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
    this.calories = 0;
  }
}

class MicroNutrients {
  final MeasuredUnit? vitaminA;
  final MeasuredUnit? vitaminC;
  final MeasuredUnit? vitaminD;
  final MeasuredUnit? vitaminE;
  final MeasuredUnit? vitaminK;
  final MeasuredUnit? thiamin; // Vitamin B1
  final MeasuredUnit? riboflavin; // Vitamin B2
  final MeasuredUnit? niacin; // Vitamin B3
  final MeasuredUnit? vitaminB6;
  final MeasuredUnit? folate; // Vitamin B9
  final MeasuredUnit? vitaminB12;
  final MeasuredUnit? pantothenicAcid; // Vitamin B5
  final MeasuredUnit? biotin; // Vitamin B7

  final MeasuredUnit? calcium;
  final MeasuredUnit? iron;
  final MeasuredUnit? magnesium;
  final MeasuredUnit? phosphorus;
  final MeasuredUnit? potassium;
  final MeasuredUnit? sodium;
  final MeasuredUnit? zinc;
  final MeasuredUnit? copper;
  final MeasuredUnit? manganese;
  final MeasuredUnit? selenium;
  final MeasuredUnit? iodine;
  final MeasuredUnit? chromium;
  final MeasuredUnit? molybdenum;
  final MeasuredUnit? fluoride;
  final MeasuredUnit? chloride;
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
  final double value;
  final String unit;
  const MeasuredUnit({required this.value, required this.unit});
}
