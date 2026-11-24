import 'package:hive/hive.dart';
import 'package:performance_tracker/core/extensions/double_extensions.dart';

part 'generated/routine.model.g.dart';

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
  /// DATE_KEY (`yyyy-MM-dd`) of the day an auto routine belongs to; it is also
  /// the routine's Hive key. Null for custom routines.
  @HiveField(5)
  String? dateKey;
  Routine({
    required this.name,
    required this.workoutsIds,
    required this.createdAt,
    required this.isCustom,
    required this.desc,
    this.dateKey,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'workoutsIds': workoutsIds,
    'createdAt': createdAt.toIso8601String(),
    'isCustom': isCustom,
    'desc': desc,
    'dateKey': dateKey,
  };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    name: json['name'] as String,
    workoutsIds: (json['workoutsIds'] as List<dynamic>).cast<int>(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isCustom: json['isCustom'] as bool,
    desc: json['desc'] as String,
    dateKey: json['dateKey'] as String?,
  );
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
    required this.volumes,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((set) => set.toJson()).toList(),
    'enabled': enabled,
    'desc': desc,
    'volumes': volumes.map((volume) => volume.toJson()).toList(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    name: json['name'] as String,
    sets: (json['sets'] as List<dynamic>)
        .map((setJson) => WorkSet.fromJson(setJson as Map<String, dynamic>))
        .toList(),
    enabled: json['enabled'] as bool,
    desc: json['desc'] as String,
    volumes: (json['volumes'] as List<dynamic>)
        .map(
          (volumeJson) =>
              WorkoutVolume.fromJson(volumeJson as Map<String, dynamic>),
        )
        .toList(),
  );
  
  // Returns reps that is assumed to be capable by user if previously no workout have been done
  double getFatigueAdjustedReps(double fatigue , int reps)
  {
    var sumOfAllVolumes = 0.0;
    volumes.forEach((vol)=> sumOfAllVolumes+=vol.volume);
    return (reps + (fatigue / sumOfAllVolumes).safe);
  }
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

  Map<String, dynamic> toJson() => {
    'value': value,
    'history': history.map((entry) => entry.toJson()).toList(),
    'pr': pr,
    'enabled': enabled,
  };

  factory WorkSet.fromJson(Map<String, dynamic> json) => WorkSet(
    value: json['value'] as double,
    history: json['history'] == null
        ? []
        : (json['history'] as List<dynamic>)
              .map(
                (entryJson) =>
                    TrackEntry.fromJson(entryJson as Map<String, dynamic>),
              )
              .toList(),
    pr: json['pr'] == null ? 0 : json['pr'] as int,
    enabled: json['enabled'] == null ? false : json['enabled'] as bool,
  );
}

@HiveType(typeId: 16)
class TrackEntry {
  @HiveField(0)
  DateTime entryDate;
  @HiveField(1)
  int value;

  /// Accumulated muscle fatigue context present when this set was performed,
  /// calculated from the daily fatigue map BEFORE this set contributed to it.
  /// Normalized to the range [0, 2]. Stored as metadata; never modifies [value].
  @HiveField(2, defaultValue: 0.0)
  double fatigueContext;

  TrackEntry({
    required this.entryDate,
    required this.value,
    this.fatigueContext = 0,
  });

  Map<String, dynamic> toJson() => {
    'entryDate': entryDate.toIso8601String(),
    'value': value,
    'fatigueContext': fatigueContext,
  };

  factory TrackEntry.fromJson(Map<String, dynamic> json) => TrackEntry(
    entryDate: DateTime.parse(json['entryDate'] as String),
    value: json['value'] as int,
    fatigueContext: (json['fatigueContext'] as num?)?.toDouble() ?? 0,
  );
}

@HiveType(typeId: 19)
class WorkoutVolume {
  @HiveField(0)
  String muscleName;
  @HiveField(1)
  double volume;
  WorkoutVolume({required this.muscleName, required this.volume});

  Map<String, dynamic> toJson() => {'muscleName': muscleName, 'volume': volume};

  factory WorkoutVolume.fromJson(Map<String, dynamic> json) => WorkoutVolume(
    muscleName: json['muscleName'] as String,
    volume: json['volume'] as double,
  );
}
