class Food
{
  final String? name;
  final List<UnitCalorieMap> caloriesData;

  const Food({this.name, required this.caloriesData});
}

class UnitCalorieMap
{
  final String unit;
  final String calories;

  const UnitCalorieMap({required this.unit , required this.calories});
}