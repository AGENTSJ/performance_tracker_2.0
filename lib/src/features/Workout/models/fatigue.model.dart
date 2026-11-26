import 'package:hive/hive.dart';

part 'generated/fatigue.model.g.dart';

// typeId 36 belonged to the retired FatigueDay (per-day running totals) and
// must not be reused.

/// The fatigue one tracked set added to each muscle.
///
/// Stored under [trackEntryId], the id of the [TrackEntry] it belongs to, so
/// removing the entry removes its fatigue. The time comes from that entry.
/// [muscleFatigue] is a copy of the workout's muscle volumes when the set was
/// tracked, so editing the workout's volumes later doesn't rewrite past
/// fatigue.
@HiveType(typeId: 38)
class FatigueEntry extends HiveObject {
  @HiveField(0)
  String trackEntryId;

  /// Muscle name -> fatigue this set added to it.
  @HiveField(1)
  Map<String, double> muscleFatigue;

  FatigueEntry({required this.trackEntryId, required this.muscleFatigue});

  Map<String, dynamic> toJson() => {
    'trackEntryId': trackEntryId,
    'muscleFatigue': muscleFatigue,
  };

  factory FatigueEntry.fromJson(Map<String, dynamic> json) => FatigueEntry(
    trackEntryId: json['trackEntryId'] as String,
    muscleFatigue: (json['muscleFatigue'] as Map<dynamic, dynamic>).map(
      (key, value) => MapEntry(key as String, (value as num).toDouble()),
    ),
  );
}

/// Fatigue accumulated on one calendar day. Calculated, never stored.
class DailyFatigue {
  final DateTime date;

  /// Muscle name -> fatigue accumulated that day.
  final Map<String, double> muscleFatigue;

  const DailyFatigue({required this.date, required this.muscleFatigue});
}
