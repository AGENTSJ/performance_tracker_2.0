import 'package:hive/hive.dart';

part 'food.model.g.dart';

@HiveType(typeId: 0)
class Food {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final MacroNutrients macros;

  @HiveField(2)
  final MicroNutrients micros;

  @HiveField(3)
  final MeasuredUnit quantity;
  
  @HiveField(4)
  final String? imageUrl;
  
  Food({
    required this.name,
    required this.macros,
    required this.micros,
    required this.quantity,
    this.imageUrl
  });

  Food clone({
    String? name,
    MacroNutrients? macros,
    MicroNutrients? micros,
    MeasuredUnit? quantity,
  }) {
    return Food(
      name: name ?? this.name,
      macros: macros ?? this.macros.clone(),
      micros: micros ?? this.micros.clone(),
      quantity: quantity ?? this.quantity.clone(),
      imageUrl: imageUrl 
    );
  }
}

@HiveType(typeId: 1)
class MacroNutrients {
  @HiveField(0)
  double protein;

  @HiveField(1)
  double fat;

  @HiveField(2)
  double carbohydrate;

  @HiveField(3)
  double fiber;

  @HiveField(4)
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

  Map<String, dynamic> toJson() => {
    'protein': protein,
    'fat': fat,
    'carbohydrate': carbohydrate,
    'fiber': fiber,
    'calories': calories,
  };
}

@HiveType(typeId: 2)
class MicroNutrients {
  @HiveField(0)
  MeasuredUnit? vitaminA;

  @HiveField(1)
  MeasuredUnit? vitaminC;

  @HiveField(2)
  MeasuredUnit? vitaminD;

  @HiveField(3)
  MeasuredUnit? vitaminE;

  @HiveField(4)
  MeasuredUnit? vitaminK;

  @HiveField(5)
  MeasuredUnit? thiamin; // Vitamin B1

  @HiveField(6)
  MeasuredUnit? riboflavin; // Vitamin B2

  @HiveField(7)
  MeasuredUnit? niacin; // Vitamin B3

  @HiveField(8)
  MeasuredUnit? vitaminB6;

  @HiveField(9)
  MeasuredUnit? folate; // Vitamin B9

  @HiveField(10)
  MeasuredUnit? vitaminB12;

  @HiveField(11)
  MeasuredUnit? pantothenicAcid; // Vitamin B5

  @HiveField(12)
  MeasuredUnit? biotin; // Vitamin B7

  @HiveField(13)
  MeasuredUnit? calcium;

  @HiveField(14)
  MeasuredUnit? iron;

  @HiveField(15)
  MeasuredUnit? magnesium;

  @HiveField(16)
  MeasuredUnit? phosphorus;

  @HiveField(17)
  MeasuredUnit? potassium;

  @HiveField(18)
  MeasuredUnit? sodium;

  @HiveField(19)
  MeasuredUnit? zinc;

  @HiveField(20)
  MeasuredUnit? copper;

  @HiveField(21)
  MeasuredUnit? manganese;

  @HiveField(22)
  MeasuredUnit? selenium;

  @HiveField(23)
  MeasuredUnit? iodine;

  @HiveField(24)
  MeasuredUnit? chromium;

  @HiveField(25)
  MeasuredUnit? molybdenum;

  @HiveField(26)
  MeasuredUnit? fluoride;

  @HiveField(27)
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
      vitaminA: vitaminA,
      vitaminC: vitaminC,
      vitaminD: vitaminD,
      vitaminE: vitaminE,
      vitaminK: vitaminK,
      thiamin: thiamin,
      riboflavin: riboflavin,
      niacin: niacin,
      vitaminB6: vitaminB6,
      folate: folate,
      vitaminB12: vitaminB12,
      pantothenicAcid: pantothenicAcid,
      biotin: biotin,
      calcium: calcium,
      iron: iron,
      magnesium: magnesium,
      phosphorus: phosphorus,
      potassium: potassium,
      sodium: sodium,
      zinc: zinc,
      copper: copper,
      manganese: manganese,
      selenium: selenium,
      iodine: iodine,
      chromium: chromium,
      molybdenum: molybdenum,
      fluoride: fluoride,
      chloride: chloride,
    );
  }

  static final Map<String, MeasuredUnit> microRDA = {
    // Vitamins
    'Vitamin A': MeasuredUnit(value: 900.0, unit: 'mcg'),
    'Vitamin C': MeasuredUnit(value: 90.0, unit: 'mg'),
    'Vitamin D': MeasuredUnit(value: 15.0, unit: 'mcg'),
    'Vitamin E': MeasuredUnit(value: 15.0, unit: 'mg'),
    'Vitamin K': MeasuredUnit(value: 120.0, unit: 'mcg'),
    'Thiamin': MeasuredUnit(value: 1.2, unit: 'mg'),
    'Riboflavin': MeasuredUnit(value: 1.3, unit: 'mg'),
    'Niacin': MeasuredUnit(value: 16.0, unit: 'mg'),
    'Vitamin B6': MeasuredUnit(value: 1.3, unit: 'mg'),
    'Folate': MeasuredUnit(value: 400.0, unit: 'mcg'),
    'Vitamin B12': MeasuredUnit(value: 2.4, unit: 'mcg'),
    'Pantothenic Acid': MeasuredUnit(value: 5.0, unit: 'mg'),
    'Biotin': MeasuredUnit(value: 30.0, unit: 'mcg'),

    // Minerals
    'Calcium': MeasuredUnit(value: 1000.0, unit: 'mg'),
    'Iron': MeasuredUnit(value: 8.0, unit: 'mg'),
    'Magnesium': MeasuredUnit(value: 400.0, unit: 'mg'),
    'Phosphorus': MeasuredUnit(value: 700.0, unit: 'mg'),
    'Potassium': MeasuredUnit(value: 4700.0, unit: 'mg'),
    'Sodium': MeasuredUnit(value: 1500.0, unit: 'mg'),
    'Zinc': MeasuredUnit(value: 11.0, unit: 'mg'),
    'Copper': MeasuredUnit(value: 0.9, unit: 'mg'),
    'Manganese': MeasuredUnit(value: 2.3, unit: 'mg'),
    'Selenium': MeasuredUnit(value: 55.0, unit: 'mcg'),
    'Iodine': MeasuredUnit(value: 150.0, unit: 'mcg'),
    'Chromium': MeasuredUnit(value: 35.0, unit: 'mcg'),
    'Molybdenum': MeasuredUnit(value: 45.0, unit: 'mcg'),
    'Fluoride': MeasuredUnit(value: 4000.0, unit: 'mcg'),
    'Chloride': MeasuredUnit(value: 2300.0, unit: 'mg'),
  };
  
}

@HiveType(typeId: 3)
class MeasuredUnit {
  @HiveField(0)
  double value;

  @HiveField(1)
  String unit;

  MeasuredUnit({required this.value, required this.unit});

  MeasuredUnit clone() {
    return MeasuredUnit(value: this.value, unit: this.unit);
  }
}
