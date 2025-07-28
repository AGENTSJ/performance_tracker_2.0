import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/models/user.model.dart';
part 'journey.model.g.dart';

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

  Journey({
    required this.startDate,
    required this.userAtStart,
    required this.caloriesChangeAchieved,
    required this.stepsWalked,
    required this.logs,
    required this.status
  });
}

@HiveType(typeId: 22)
class JourneyLog {
  @HiveField(0)
  int dayId;
  @HiveField(1)
  User userAtDay;

  JourneyLog({required this.dayId,required this.userAtDay});
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