import 'package:hive/hive.dart';

part 'fatigue.model.g.dart';

/// Accumulated muscle fatigue for a single calendar day.
///
/// Fatigue accumulates throughout the day and is shared across every workout
/// performed on that day. Because records are keyed by [dateKey], a new day
/// simply has no record yet, which means the fatigue map is effectively reset
/// when a new day begins.
@HiveType(typeId: 36)
class FatigueDay extends HiveObject {
  /// Calendar day this fatigue belongs to. Format: "year-month-day".
  @HiveField(0)
  String dateKey;

  /// Map of muscle name -> accumulated fatigue for the day.
  @HiveField(1)
  Map<String, double> muscleFatigue;

  FatigueDay({required this.dateKey, required this.muscleFatigue});

  Map<String, dynamic> toJson() => {
    'dateKey': dateKey,
    'muscleFatigue': muscleFatigue,
  };

  factory FatigueDay.fromJson(Map<String, dynamic> json) => FatigueDay(
    dateKey: json['dateKey'] as String,
    muscleFatigue: (json['muscleFatigue'] as Map<dynamic, dynamic>).map(
      (key, value) => MapEntry(key as String, (value as num).toDouble()),
    ),
  );
}
