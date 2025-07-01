import 'package:hive/hive.dart';

part 'user.model.g.dart';

@HiveType(typeId: 9)
enum Gender {
  @HiveField(0)
  male,
  @HiveField(1)
  female,
  @HiveField(2)
  other,
}

@HiveType(typeId: 10)
enum ActivityLevel {
  @HiveField(0)
  sedentary,
  @HiveField(1)
  lightlyActive,
  @HiveField(2)
  moderatelyActive,
  @HiveField(3)
  veryActive,
  @HiveField(4)
  extraActive,
}

@HiveType(typeId: 11)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  Gender gender;

  @HiveField(3)
  double height; 

  @HiveField(4)
  double weight;

  @HiveField(5)
  ActivityLevel? activityLevel;

  @HiveField(6)
  UserGoals userGoals;

  @HiveField(7)
  int id;

  @HiveField(8)
  DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.userGoals,
    required this.createdAt,
  });
}

@HiveType(typeId: 12)
class UserGoals
{
  @HiveField(1)
  double calorieLimit;
  
  @HiveField(2)
  int stepGoal;

  @HiveField(3)
  double targetWeight;

  @HiveField(4)
  double caloricChangeGoal;
  
  UserGoals({
    required this.calorieLimit,
    required this.stepGoal,
    required this.targetWeight,
    required this.caloricChangeGoal,
  });
}