import 'package:hive/hive.dart';
part 'activity.model.g.dart';

@HiveType(typeId: 17)
class Activity
{
  @HiveField(0)
  int steps;
  Activity({required this.steps});

  Map<String, dynamic> toJson() => {
    'steps': steps,
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    steps: json['steps'] as int,
  );
}