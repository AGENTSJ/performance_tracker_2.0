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

  @HiveField(5)
  final List<MeasuredUnit> servings;
  
  Food({
    required this.name,
    required this.macros,
    required this.micros,
    required this.quantity,
    this.imageUrl,
    required this.servings,
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
      imageUrl: imageUrl ,
      servings: this.servings
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'macros': macros.toJson(),
    'micros': micros.toJson(),
    'quantity': quantity.toJson(),
    'imageUrl': imageUrl,
    'servings': servings.map((serving) => serving.toJson()).toList(),
  };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    name: json['name'] as String,
    macros: MacroNutrients.fromJson(json['macros'] as Map<String, dynamic>),
    micros: MicroNutrients.fromJson(json['micros'] as Map<String, dynamic>),
    quantity: MeasuredUnit.fromJson(json['quantity'] as Map<String, dynamic>),
    imageUrl: json['imageUrl'] as String?,
    servings: (json['servings'] as List<dynamic>)
        .map((servingJson) => MeasuredUnit.fromJson(servingJson as Map<String, dynamic>))
        .toList(),
  );
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

  factory MacroNutrients.fromJson(Map<String, dynamic> json) => MacroNutrients(
    json['protein'] as double,
    json['carbohydrate'] as double,
    json['fat'] as double,
    json['fiber'] as double,
    json['calories'] as double,
  );
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

  Map<String, dynamic> toJson() => {
    'vitaminA': vitaminA?.toJson(),
    'vitaminC': vitaminC?.toJson(),
    'vitaminD': vitaminD?.toJson(),
    'vitaminE': vitaminE?.toJson(),
    'vitaminK': vitaminK?.toJson(),
    'thiamin': thiamin?.toJson(),
    'riboflavin': riboflavin?.toJson(),
    'niacin': niacin?.toJson(),
    'vitaminB6': vitaminB6?.toJson(),
    'folate': folate?.toJson(),
    'vitaminB12': vitaminB12?.toJson(),
    'pantothenicAcid': pantothenicAcid?.toJson(),
    'biotin': biotin?.toJson(),
    'calcium': calcium?.toJson(),
    'iron': iron?.toJson(),
    'magnesium': magnesium?.toJson(),
    'phosphorus': phosphorus?.toJson(),
    'potassium': potassium?.toJson(),
    'sodium': sodium?.toJson(),
    'zinc': zinc?.toJson(),
    'copper': copper?.toJson(),
    'manganese': manganese?.toJson(),
    'selenium': selenium?.toJson(),
    'iodine': iodine?.toJson(),
    'chromium': chromium?.toJson(),
    'molybdenum': molybdenum?.toJson(),
    'fluoride': fluoride?.toJson(),
    'chloride': chloride?.toJson(),
  };

  factory MicroNutrients.fromJson(Map<String, dynamic> json) => MicroNutrients(
    vitaminA: json['vitaminA'] != null 
        ? MeasuredUnit.fromJson(json['vitaminA'] as Map<String, dynamic>)
        : null,
    vitaminC: json['vitaminC'] != null 
        ? MeasuredUnit.fromJson(json['vitaminC'] as Map<String, dynamic>)
        : null,
    vitaminD: json['vitaminD'] != null 
        ? MeasuredUnit.fromJson(json['vitaminD'] as Map<String, dynamic>)
        : null,
    vitaminE: json['vitaminE'] != null 
        ? MeasuredUnit.fromJson(json['vitaminE'] as Map<String, dynamic>)
        : null,
    vitaminK: json['vitaminK'] != null 
        ? MeasuredUnit.fromJson(json['vitaminK'] as Map<String, dynamic>)
        : null,
    thiamin: json['thiamin'] != null 
        ? MeasuredUnit.fromJson(json['thiamin'] as Map<String, dynamic>)
        : null,
    riboflavin: json['riboflavin'] != null 
        ? MeasuredUnit.fromJson(json['riboflavin'] as Map<String, dynamic>)
        : null,
    niacin: json['niacin'] != null 
        ? MeasuredUnit.fromJson(json['niacin'] as Map<String, dynamic>)
        : null,
    vitaminB6: json['vitaminB6'] != null 
        ? MeasuredUnit.fromJson(json['vitaminB6'] as Map<String, dynamic>)
        : null,
    folate: json['folate'] != null 
        ? MeasuredUnit.fromJson(json['folate'] as Map<String, dynamic>)
        : null,
    vitaminB12: json['vitaminB12'] != null 
        ? MeasuredUnit.fromJson(json['vitaminB12'] as Map<String, dynamic>)
        : null,
    pantothenicAcid: json['pantothenicAcid'] != null 
        ? MeasuredUnit.fromJson(json['pantothenicAcid'] as Map<String, dynamic>)
        : null,
    biotin: json['biotin'] != null 
        ? MeasuredUnit.fromJson(json['biotin'] as Map<String, dynamic>)
        : null,
    calcium: json['calcium'] != null 
        ? MeasuredUnit.fromJson(json['calcium'] as Map<String, dynamic>)
        : null,
    iron: json['iron'] != null 
        ? MeasuredUnit.fromJson(json['iron'] as Map<String, dynamic>)
        : null,
    magnesium: json['magnesium'] != null 
        ? MeasuredUnit.fromJson(json['magnesium'] as Map<String, dynamic>)
        : null,
    phosphorus: json['phosphorus'] != null 
        ? MeasuredUnit.fromJson(json['phosphorus'] as Map<String, dynamic>)
        : null,
    potassium: json['potassium'] != null 
        ? MeasuredUnit.fromJson(json['potassium'] as Map<String, dynamic>)
        : null,
    sodium: json['sodium'] != null 
        ? MeasuredUnit.fromJson(json['sodium'] as Map<String, dynamic>)
        : null,
    zinc: json['zinc'] != null 
        ? MeasuredUnit.fromJson(json['zinc'] as Map<String, dynamic>)
        : null,
    copper: json['copper'] != null 
        ? MeasuredUnit.fromJson(json['copper'] as Map<String, dynamic>)
        : null,
    manganese: json['manganese'] != null 
        ? MeasuredUnit.fromJson(json['manganese'] as Map<String, dynamic>)
        : null,
    selenium: json['selenium'] != null 
        ? MeasuredUnit.fromJson(json['selenium'] as Map<String, dynamic>)
        : null,
    iodine: json['iodine'] != null 
        ? MeasuredUnit.fromJson(json['iodine'] as Map<String, dynamic>)
        : null,
    chromium: json['chromium'] != null 
        ? MeasuredUnit.fromJson(json['chromium'] as Map<String, dynamic>)
        : null,
    molybdenum: json['molybdenum'] != null 
        ? MeasuredUnit.fromJson(json['molybdenum'] as Map<String, dynamic>)
        : null,
    fluoride: json['fluoride'] != null 
        ? MeasuredUnit.fromJson(json['fluoride'] as Map<String, dynamic>)
        : null,
    chloride: json['chloride'] != null 
        ? MeasuredUnit.fromJson(json['chloride'] as Map<String, dynamic>)
        : null,
  );

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

  Map<String, dynamic> toJson() => {
    'value': value,
    'unit': unit,
  };

  factory MeasuredUnit.fromJson(Map<String, dynamic> json) => MeasuredUnit(
    value: json['value'] as double,
    unit: json['unit'] as String,
  );
}

