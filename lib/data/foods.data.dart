import 'package:performance_tracker/models/food.model.dart';

final List<Food> availableFoods = [
  // 1. Chicken Breast (cooked)
  Food(
    name: 'Chicken Breast (cooked)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(31.0, 0.0, 3.6, 0.0, 165.0),
    micros: MicroNutrients(
      vitaminB6: MeasuredUnit(value: 0.6, unit: 'mg'),
      phosphorus: MeasuredUnit(value: 210, unit: 'mg'),
      niacin: MeasuredUnit(value: 13.7, unit: 'mg'),
      selenium: MeasuredUnit(value: 27.6, unit: 'µg'),
    ),
  ),

  // 2. Egg (whole, boiled)
  Food(
    name: 'Boiled Egg',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(13.0, 1.1, 11.0, 0.0, 155.0),
    micros: MicroNutrients(
      vitaminB12: MeasuredUnit(value: 1.1, unit: 'µg'),
      vitaminA: MeasuredUnit(value: 160, unit: 'µg'),
      iron: MeasuredUnit(value: 1.2, unit: 'mg'),
      selenium: MeasuredUnit(value: 30.8, unit: 'µg'),
    ),
  ),

  // 3. Milk (whole, cow)
  Food(
    name: 'Whole Milk (cow)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(3.2, 4.8, 3.7, 0.0, 61.0),
    micros: MicroNutrients(
      calcium: MeasuredUnit(value: 113, unit: 'mg'),
      vitaminB12: MeasuredUnit(value: 0.4, unit: 'µg'),
      riboflavin: MeasuredUnit(value: 0.2, unit: 'mg'),
      phosphorus: MeasuredUnit(value: 84, unit: 'mg'),
    ),
  ),

  // 4. Brown Rice (cooked)
  Food(
    name: 'Brown Rice (cooked)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(2.6, 23.0, 0.9, 1.8, 111.0),
    micros: MicroNutrients(
      magnesium: MeasuredUnit(value: 39, unit: 'mg'),
      phosphorus: MeasuredUnit(value: 103, unit: 'mg'),
    ),
  ),

  // 5. Apple (raw)
  Food(
    name: 'Apple (raw)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(0.3, 13.8, 0.2, 2.4, 52.0),
    micros: MicroNutrients(
      vitaminC: MeasuredUnit(value: 4.6, unit: 'mg'),
      potassium: MeasuredUnit(value: 107, unit: 'mg'),
    ),
  ),

  // 6. Banana (raw)
  Food(
    name: 'Banana (raw)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(1.1, 22.8, 0.3, 2.6, 89.0),
    micros: MicroNutrients(
      vitaminC: MeasuredUnit(value: 8.7, unit: 'mg'),
      potassium: MeasuredUnit(value: 358, unit: 'mg'),
      vitaminB6: MeasuredUnit(value: 0.4, unit: 'mg'),
    ),
  ),

  // 7. Broccoli (raw)
  Food(
    name: 'Broccoli (raw)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(2.8, 6.6, 0.4, 2.6, 34.0),
    micros: MicroNutrients(
      vitaminC: MeasuredUnit(value: 89.2, unit: 'mg'),
      vitaminK: MeasuredUnit(value: 101.6, unit: 'µg'),
      folate: MeasuredUnit(value: 63, unit: 'µg'),
    ),
  ),

  // 8. Carrot (raw)
  Food(
    name: 'Carrot (raw)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(0.9, 9.6, 0.2, 2.8, 41.0),
    micros: MicroNutrients(
      vitaminA: MeasuredUnit(value: 835, unit: 'µg'),
      vitaminK: MeasuredUnit(value: 13.2, unit: 'µg'),
      potassium: MeasuredUnit(value: 320, unit: 'mg'),
    ),
  ),

  // 9. Almonds (raw)
  Food(
    name: 'Almonds (raw)',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(21.2, 21.6, 49.4, 12.5, 579.0),
    micros: MicroNutrients(
      magnesium: MeasuredUnit(value: 268, unit: 'mg'),
      calcium: MeasuredUnit(value: 269, unit: 'mg'),
      iron: MeasuredUnit(value: 3.7, unit: 'mg'),
    ),
  ),

  // 10. Olive Oil
  Food(
    name: 'Olive Oil',
    baseUnit: MeasuredUnit(value: 100, unit: 'g'),
    macros: MacroNutrients(0.0, 0.0, 100.0, 0.0, 884.0),
    micros: MicroNutrients(
      vitaminE: MeasuredUnit(value: 14.4, unit: 'mg'),
      vitaminK: MeasuredUnit(value: 60.2, unit: 'µg'),
    ),
  ),
];
