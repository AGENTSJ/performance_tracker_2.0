import 'package:hive/hive.dart';

// part 'routine.model.g.dart';

@HiveType(typeId: 13)
class Routine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<int> workoutsIds;

  Routine({required this.name, required this.workoutsIds});
}

@HiveType(typeId: 14)
class Workout extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Set> sets;

  Workout({required this.name, required this.sets});
}

@HiveType(typeId: 15)
class Set extends HiveObject {
  @HiveField(0)
  int value;

  @HiveField(1)
  List<int> history;

  @HiveField(2)
  int pr;

  Set({required this.value, required this.history, required this.pr});
}

var demoWorkOut = [
  Workout(
    name: 'Bench Press',
    sets: [
      Set(value: 10, history: [8, 10, 12], pr: 12),
      Set(value: 8, history: [6, 8, 10], pr: 10),
    ],
  ),
  Workout(
    name: 'Squat',
    sets: [
      Set(value: 12, history: [10, 12, 14], pr: 14),
      Set(value: 10, history: [8, 10, 12], pr: 12),
    ],
  ),
  Workout(
    name: 'Deadlift',
    sets: [
      Set(value: 6, history: [5, 6, 7], pr: 7),
      Set(value: 5, history: [4, 5, 6], pr: 6),
    ],
  ),
];