import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/core/models/user.model.dart';
part 'generated/journey.model.g.dart';

@HiveType(typeId: 18)
class Journey extends HiveObject {
  @HiveField(0)
  DateTime startDate;

  @HiveField(1)
  User userAtStart;

  @HiveField(2)
  double caloriesChangeAchieved;

  @HiveField(3)
  int stepsWalked;

  @HiveField(4)
  DateTime? lastUpdated;

  @HiveField(5)
  double? lastCaloriesValue;

  @HiveField(6)
  int? lastStepValue;

  @HiveField(7)
  List<JourneyLog> logs;

  @HiveField(8)
  JourneyStatus status;
  
  @HiveField(9)
  String? reasonToStop;

  /// Id of the user goal this journey is measured against. Goals are locked
  /// while a journey is active, so it stays the active goal throughout.
  /// Null for journeys from before goal periods (they keep using
  /// `userAtStart.userGoals`).
  @HiveField(10)
  int? goalId;

  Journey({
    required this.startDate,
    required this.userAtStart,
    required this.caloriesChangeAchieved,
    required this.stepsWalked,
    required this.logs,
    required this.status,
    this.goalId,
  });

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'userAtStart': userAtStart.toJson(),
    'caloriesChangeAchieved': caloriesChangeAchieved,
    'stepsWalked': stepsWalked,
    'lastUpdated': lastUpdated?.toIso8601String(),
    'lastCaloriesValue': lastCaloriesValue,
    'lastStepValue': lastStepValue,
    'logs': logs.map((log) => log.toJson()).toList(),
    'status': status.name,
    'reasonToStop': reasonToStop,
    'goalId': goalId,
  };

  factory Journey.fromJson(Map<String, dynamic> json) => Journey(
    startDate: DateTime.parse(json['startDate'] as String),
    userAtStart: User.fromJson(json['userAtStart'] as Map<String, dynamic>),
    caloriesChangeAchieved: json['caloriesChangeAchieved'] as double,
    stepsWalked: json['stepsWalked'] as int,
    logs: (json['logs'] as List<dynamic>)
        .map((logJson) => JourneyLog.fromJson(logJson as Map<String, dynamic>))
        .toList(),
    status: JourneyStatus.values.firstWhere((e) => e.name == json['status']),
    goalId: json['goalId'] as int?,
  )
    ..lastUpdated = json['lastUpdated'] != null 
        ? DateTime.parse(json['lastUpdated'] as String)
        : null
    ..lastCaloriesValue = json['lastCaloriesValue'] as double?
    ..lastStepValue = json['lastStepValue'] as int?
    ..reasonToStop = json['reasonToStop'] as String?;
}

@HiveType(typeId: 22)
class JourneyLog {
  /// Legacy: the old auto-increment day key. New logs use [dateKey].
  @HiveField(0)
  int? dayId;
  @HiveField(1)
  User userAtDay;
  /// DATE_KEY (`yyyy-MM-dd`) of the logged day.
  @HiveField(2)
  String? dateKey;

  JourneyLog({this.dayId, this.dateKey, required this.userAtDay});

  Map<String, dynamic> toJson() => {
    'dayId': dayId,
    'dateKey': dateKey,
    'userAtDay': userAtDay.toJson(),
  };

  factory JourneyLog.fromJson(Map<String, dynamic> json) => JourneyLog(
    dayId: json['dayId'] as int?,
    dateKey: json['dateKey'] as String?,
    userAtDay: User.fromJson(json['userAtDay'] as Map<String, dynamic>),
  );
}

@HiveType(typeId:23)
enum JourneyStatus
{
  @HiveField(0)
  onProgress,
  @HiveField(1)
  failed,
  @HiveField(2)
  completed

}