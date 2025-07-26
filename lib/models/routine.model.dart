import 'package:hive/hive.dart';

part 'routine.model.g.dart';

@HiveType(typeId: 13)
class Routine extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<int> workoutsIds;
  @HiveField(2)
  DateTime createdAt;
  @HiveField(3)
  bool isCustom;
  @HiveField(4)
  String desc;
  Routine({
    required this.name,
    required this.workoutsIds,
    required this.createdAt,
    required this.isCustom,
    required this.desc,
  });
}

@HiveType(typeId: 14)
class Workout extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<WorkSet> sets;
  @HiveField(2)
  bool enabled;
  @HiveField(3)
  String desc;
  @HiveField(4)
  List<WorkoutVolume> volumes;

  Workout({
    required this.name,
    required this.sets,
    required this.enabled,
    required this.desc,
    required this.volumes
  });
}

@HiveType(typeId: 15)
class WorkSet extends HiveObject {
  @HiveField(0)
  double value;

  @HiveField(1)
  List<TrackEntry> history;

  @HiveField(2)
  int pr;

  @HiveField(3)
  bool enabled;

  WorkSet({
    required this.value,
    required this.history,
    required this.pr,
    required this.enabled,
  });
}

@HiveType(typeId: 16)
class TrackEntry {
  @HiveField(0)
  DateTime entryDate;
  @HiveField(1)
  int value;
  TrackEntry({required this.entryDate, required this.value});
}

@HiveType(typeId:19)
class WorkoutVolume
{
  @HiveField(0)
  String muscleName;
  @HiveField(1)
  double volume;
  WorkoutVolume({required this.muscleName,required this.volume});
}