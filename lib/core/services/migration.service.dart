import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/core/models/day.model.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Dashboard/models/journey.model.dart';

/// Every data migration lives in this file, so services and repositories stay
/// free of legacy handling.
///
/// To add a migration: write a private method below and append it to
/// [_startupMigrations]. Each one runs on every launch, so it must check
/// whether there is anything left to migrate and be safe to re-run if it was
/// interrupted.
class MigrationService {
  final _commonService = locator<CommonService>();

  late final List<Future<void> Function()> _startupMigrations = [
    _migrateDaysToDateKey,
  ];

  /// Runs all startup migrations in order. Call after the Hive boxes are open.
  Future<void> runStartupMigrations() async {
    for (final migration in _startupMigrations) {
      await migration();
    }
  }

  /// Brings data restored from an older backup up to the current format,
  /// before it is saved.
  void migrateImportedData({
    required List<Day> days,
    required List<Journey> journeys,
  }) {
    // Older backups point journey logs at days by position, not DATE_KEY.
    for (final journey in journeys) {
      for (final log in journey.logs) {
        final id = log.dayId;
        if (log.dateKey == null && id != null && id >= 0 && id < days.length) {
          log.dateKey = _commonService.getDateKey(days[id].dayTime);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Days keyed by DATE_KEY
  //
  // Days used to be stored under auto-increment int keys, and journey logs
  // pointed at them by that id. Days now live under their DATE_KEY
  // (`yyyy-MM-dd`). Journey logs are pointed at the date first, while the old
  // keys still exist, then the days are re-keyed.
  // ---------------------------------------------------------------------------

  Future<void> _migrateDaysToDateKey() async {
    final dayBox = Hive.box<Day>(Collections.days.value);
    final legacyKeys = dayBox.keys.whereType<int>().toList()..sort();
    if (legacyKeys.isEmpty) return;

    String keyOf(Day day) => _commonService.getDateKey(day.dayTime);

    // 1. Journey logs: old id -> DATE_KEY. Logs were written with the day's
    //    key but read back with getAt(id), so fall back to the box index.
    final byKey = {for (final k in legacyKeys) k: keyOf(dayBox.get(k)!)};
    final byIndex = dayBox.values.map(keyOf).toList();
    final journeyBox = Hive.box<Journey>(Collections.journey.value);
    for (final journey in journeyBox.values) {
      var changed = false;
      for (final log in journey.logs) {
        final id = log.dayId;
        if (log.dateKey != null || id == null) continue;
        final dateKey =
            byKey[id] ?? (id >= 0 && id < byIndex.length ? byIndex[id] : null);
        if (dateKey != null) {
          log.dateKey = dateKey;
          changed = true;
        }
      }
      if (changed) await journey.save();
    }

    // 2. Re-key days. When several legacy days share a date, the first one
    //    holding food wins (else the first one), matching the old lookup.
    final chosen = <String, int>{};
    for (final key in legacyKeys) {
      final day = dayBox.get(key)!;
      final dateKey = keyOf(day);
      final current = chosen[dateKey];
      if (current == null ||
          (!_hasFood(dayBox.get(current)!) && _hasFood(day))) {
        chosen[dateKey] = key;
      }
    }
    for (final entry in chosen.entries) {
      if (dayBox.containsKey(entry.key)) continue; // already migrated
      // A HiveObject can't live under two keys, so store a fresh instance.
      await dayBox.put(entry.key, _copyDay(dayBox.get(entry.value)!));
    }
    await dayBox.deleteAll(legacyKeys);
  }

  bool _hasFood(Day day) {
    return (day.meals ?? []).any((meal) => meal.foods.isNotEmpty);
  }

  Day _copyDay(Day day) {
    return Day(dayTime: day.dayTime)
      ..breakFast = day.breakFast
      ..lunch = day.lunch
      ..morningSnacks = day.morningSnacks
      ..dinner = day.dinner
      ..eveningSnacks = day.eveningSnacks
      ..meals = day.meals
      ..comments = day.comments
      ..goalForToday = day.goalForToday
      ..routineId = day.routineId
      ..activity = day.activity;
  }
}
