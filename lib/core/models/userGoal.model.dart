import 'package:hive/hive.dart';

part 'generated/userGoal.model.g.dart';

/// A user goal covering a period of days. Goals never overlap and exactly one
/// is active: the active goal has no [endDate]. Its Hive key is its id.
@HiveType(typeId: 37)
class UserGoal extends HiveObject {
  /// First day of the period (date only).
  @HiveField(0)
  DateTime startDate;

  /// Last day of the period (date only); null while the goal is active.
  @HiveField(1)
  DateTime? endDate;

  @HiveField(2)
  bool isActive;

  @HiveField(3)
  int stepGoal;

  @HiveField(4)
  double targetWeight;

  @HiveField(5)
  double caloricChangeGoal;

  UserGoal({
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.stepGoal,
    required this.targetWeight,
    required this.caloricChangeGoal,
  });

  /// The goal's id (its Hive key), once stored.
  int? get id => key as int?;

  /// Id read from a backup, so a restore can store the goal under the same
  /// id that journeys reference. Not stored in Hive.
  int? backupId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isActive': isActive,
    'stepGoal': stepGoal,
    'targetWeight': targetWeight,
    'caloricChangeGoal': caloricChangeGoal,
  };

  factory UserGoal.fromJson(Map<String, dynamic> json) => UserGoal(
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: json['endDate'] != null
        ? DateTime.parse(json['endDate'] as String)
        : null,
    isActive: json['isActive'] as bool,
    stepGoal: json['stepGoal'] as int,
    targetWeight: (json['targetWeight'] as num).toDouble(),
    caloricChangeGoal: (json['caloricChangeGoal'] as num).toDouble(),
  )..backupId = json['id'] as int?;
}
