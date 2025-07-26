import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/models/user.model.dart';
part 'journey.model.g.dart';

@HiveType(typeId: 18)
class Journey extends HiveObject{
  @HiveField(0)
  DateTime startDate;

  @HiveField(1)
  User userAtStart;

  @HiveField(2)
  double caloriesChangeAchieved;

  @HiveField(3)
  int stepsWalked;

  @HiveField(4)
  bool onProgress;

  @HiveField(5)
  DateTime? lastUpdated;

  @HiveField(6)
  double? lastCaloriesValue;

  @HiveField(7)
  int? lastStepValue;
  
  Journey({
    required this.startDate,
    required this.userAtStart,
    required this.caloriesChangeAchieved,
    required this.stepsWalked,
    required this.onProgress,
  });
}
