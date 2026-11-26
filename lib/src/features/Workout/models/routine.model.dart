import 'dart:math';

import 'package:hive/hive.dart';
import 'package:performance_tracker/constants.dart';
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
  // percent drop (0 -> 100) after a set
  @HiveField(5)
  double? percentDrop;

  Workout({
    required this.name,
    required this.sets,
    required this.enabled,
    required this.desc,
    required this.volumes,
    this.percentDrop,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((set) => set.toJson()).toList(),
    'enabled': enabled,
    'desc': desc,
    'volumes': volumes.map((volume) => volume.toJson()).toList(),
    'percentDrop': percentDrop,
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
    percentDrop: (json['percentDrop'] as num?)?.toDouble(),
  );

  // Returns reps that is assumed to be capable by user if previously no workout have been done
  double getFatigueAdjustedReps(double fatigue, int reps) {
    var sumOfAllVolumes = 0.0;
    volumes.forEach((vol) => sumOfAllVolumes += vol.volume);
    final percentageDrop = percentDrop ?? (PERCENTAGE_DROP_PER_SET);
    final numberOfEquivalentSetDone = (fatigue / sumOfAllVolumes).safe;
    // var adjustedReps = reps * (1 +  numberOfEquivalentSetDone * normPercentDrop); //linear drop formula
    // var adjustedReps =
    //     reps /
    //     (1 -
    //         exponentialSaturatedCurve(
    //           numberOfEquivalentSetDone,
    //           normPercentDrop,
    //         ));
    var adjustedReps =(100 *
      reps) /
      (100 -
          exponentialSaturatedCurve(
            numberOfEquivalentSetDone,
            percentageDrop,
          ))
      ;
    return adjustedReps;
  }
}

// x = 100 * (1-e^-d * y)
// X is the percentage of performance lost , Y is the sets done , d is the  loss rate of performance meaning fatigue 1 get 15 % loss assumed
// 100 since performance cannot loose after 100 %. at 100 % u are dead.
// assumption that drop in performance is not linear given a fatigue level
double exponentialSaturatedCurve(double setsDone, double percentageDrop) {
  var d = findDecayRateForExponentialFunction(percentageDrop, 1);
  var dropPercentAfterSetsDone = 100 * (1 - exp(-1 * d * setsDone));
  return dropPercentAfterSetsDone;
}

double findDecayRateForExponentialFunction(double x, double y) {
  var d = -1 * log((x - 100).abs() / 100) * 1 / y;
  return d;
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

final _idRandom = Random();

/// A unique id for a [TrackEntry]: the creation time plus a random suffix.
String generateTrackEntryId() =>
    '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
    '-${_idRandom.nextInt(1 << 32).toRadixString(36)}';

@HiveType(typeId: 16)
class TrackEntry {
  @HiveField(0)
  DateTime entryDate;
  @HiveField(1)
  int value;

  // Field 2 held a stored fatigue context. Fatigue is now calculated from the
  // fatigue records (see FatigueService), so 2 must not be reused.

  /// Unique id. The entry's fatigue record is stored under it, so removing an
  /// entry can remove its fatigue too. Entries saved before ids existed read
  /// back with an empty value and get a fresh id here.
  @HiveField(3, defaultValue: '')
  String id;

  TrackEntry({required this.entryDate, required this.value, String? id})
    : id = (id == null || id.isEmpty) ? generateTrackEntryId() : id;

  Map<String, dynamic> toJson() => {
    'id': id,
    'entryDate': entryDate.toIso8601String(),
    'value': value,
  };

  factory TrackEntry.fromJson(Map<String, dynamic> json) => TrackEntry(
    id: json['id'] as String?,
    entryDate: DateTime.parse(json['entryDate'] as String),
    value: json['value'] as int,
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
