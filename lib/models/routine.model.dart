import 'package:hive/hive.dart';

part 'routine.model.g.dart';

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
  List<WorkSet> sets;
  
  @HiveField(2)
  bool enabled;
  
  Workout({required this.name, required this.sets,required this.enabled});
}

@HiveType(typeId: 15)
class WorkSet extends HiveObject {
  @HiveField(0)
  double value;

  @HiveField(1)
  List<int> history;

  @HiveField(2)
  int pr;

  @HiveField(3)
  bool enabled;

  WorkSet({required this.value, required this.history, required this.pr,required this.enabled});
}