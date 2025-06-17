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

  Food clone({
    String? name,
    MacroNutrients? macros,
    MicroNutrients? micros,
    MeasuredUnit? quantity,
  }) {
    return  Food(
      name: name ?? this.name,
      macros: macros ?? this.macros.clone(),
      micros: micros ?? this.micros.clone(),
      quantity: quantity ?? this.quantity.clone(),
    );
  }
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
    this.calories = protein * 4 + carbohydrate * 4 + fat * 9;
  }

  MacroNutrients clone() {
    return MacroNutrients(
      this.protein,
      this.carbohydrate,
      this.fat,
      this.fiber,
      this.calories,
    );
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
  late Map<String, MeasuredUnit?> microMap;

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

  MicroNutrients clone() {
    return MicroNutrients(
      vitaminA:  this.vitaminA,
      vitaminC:  this.vitaminC,
      vitaminD:  this.vitaminD,
      vitaminE:  this.vitaminE,
      vitaminK:  this.vitaminK,
      thiamin:  this.thiamin,
      riboflavin:  this.riboflavin,
      niacin:  this.niacin,
      vitaminB6:  this.vitaminB6,
      folate:  this.folate,
      vitaminB12:  this.vitaminB12,
      pantothenicAcid:  this.pantothenicAcid,
      biotin:  this.biotin,
      calcium:  this.calcium,
      iron:  this.iron,
      magnesium:  this.magnesium,
      phosphorus:  this.phosphorus,
      potassium:  this.potassium,
      sodium:  this.sodium,
      zinc:  this.zinc,
      copper:  this.copper,
      manganese:  this.manganese,
      selenium:  this.selenium,
      iodine:  this.iodine,
      chromium:  this.chromium,
      molybdenum:  this.molybdenum,
      fluoride:  this.fluoride,
      chloride:  this.chloride,
    );
  }
}

class MeasuredUnit {
  double value;
  String unit;
  MeasuredUnit({required this.value, required this.unit});

  MeasuredUnit clone() {
    return MeasuredUnit(value:  this.value, unit:  this.unit);
  }
}
