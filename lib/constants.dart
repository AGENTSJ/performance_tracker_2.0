const MAX_FOOD_QUANTITY_LIMIT = 1000.0;
const double minimumHumanHeightInCm = 50;
const double maximumHumanHeightInCm = 275.0; 

const double minimumHumanWeightInKg = 20.0; // Minimum plausible human weight in kg
const double maximumHumanWeightInKg = 635.0; // Maximum recorded human weight in kg
final double CALORIE_DEFICIT_LIMIT = 500;
final double CAL_SURPLUS_LIMIT = 300;
final int STANDARD_STEP_LIMIT = 5000;
final double CALORIES_IN_1KG_FAT = 7700;

// Maintenance journey tuning
// Treat the user as "maintaining" when their target weight is within this many
// kg of their current weight (or when they have no caloric change goal).
final double MAINTENANCE_WEIGHT_TOLERANCE_KG = 0.5;
// A day counts as "on track" while maintaining if its calories are within this
// percentage (+/-) of that day's maintenance calories.
final double MAINTENANCE_ADHERENCE_TOLERANCE_PERCENT = 10;
// Length of a maintenance journey, measured in adherent days.
final int MAINTENANCE_JOURNEY_DAYS = 30;

final double RECOMMENDED_B_M_I = 21.0;
final List<String> TRAINABLE_MUSCLES = [
  'Chest',
  'Back',
  'Shoulders',
  'Biceps',
  'Triceps',
  'Forearms',
  'Abdominals',
  'Obliques',
  'Glutes',
  'Quadriceps',
  'Hamstrings',
  'Calves',
  'Traps',
  'Lats',
  'Neck',
  'Lower Back',
  'Hip Flexors',
  'Adductors',
  'Abductors',
];
