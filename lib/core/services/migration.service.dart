import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/core/models/day.model.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/core/services/log.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:performance_tracker/src/features/Dashboard/models/journey.model.dart';

class _StartupMigration {
  final int index;
  final String name;
  final Future<void> Function() run;
  _StartupMigration(this.index, this.name, this.run);
}

/// Every data migration lives in this file, so services and repositories stay
/// free of legacy handling.
///
/// Startup migrations are numbered. The highest index that has run on this
/// device is kept in SharedPreferences, and on launch only migrations with a
/// higher index run, in ascending order. A device with no stored index
/// (fresh install, or an install from before this tracking) starts at 0 and
/// runs them all, so every migration must cope with empty data.
///
/// To add a migration: write a private method below and register it in
/// [_registerStartupMigrations] with the next unused index. Keep a cheap
/// "anything left to do?" check at its start: if the app is killed midway
/// the index has not moved yet, so it runs again on the next launch.
class MigrationService {
  static const _ranIndexKey = 'migrationRanIndex';

  final _commonService = locator<CommonService>();
  final _logService = locator<LogService>();
  final Map<int, _StartupMigration> _startupMigrations = {};

  MigrationService() {
    _registerStartupMigrations();
  }

  void _registerStartupMigrations() {
    _register(1, 'Days keyed by DATE_KEY', _migrateDaysToDateKey);
  }

  void _register(int index, String name, Future<void> Function() run) {
    if (index <= 0) {
      throw StateError('Migration index must be positive: $index ($name)');
    }
    final existing = _startupMigrations[index];
    if (existing != null) {
      throw StateError(
          'Duplicate migration index $index: "${existing.name}" and "$name"');
    }
    _startupMigrations[index] = _StartupMigration(index, name, run);
  }

  /// Runs every registered migration above this device's ran index, in
  /// order, saving the index after each success. On failure it logs, stops,
  /// and leaves that migration and later ones to retry on the next launch.
  /// Call after the Hive boxes are open.
  Future<void> runStartupMigrations() async {
    final prefs = await SharedPreferences.getInstance();
    final ranIndex = prefs.getInt(_ranIndexKey) ?? 0;
    final pending = _startupMigrations.values
        .where((m) => m.index > ranIndex)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    for (final migration in pending) {
      try {
        await migration.run();
      } catch (e) {
        await _logService.addErrorLog('migration',
            'Migration ${migration.index} "${migration.name}" failed: $e');
        return;
      }
      await prefs.setInt(_ranIndexKey, migration.index);
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
  // 1. Days keyed by DATE_KEY
  //
  // Days used to be stored under auto-increment int keys, and journey logs
  // pointed at them by that id. Days now live under their DATE_KEY
  // (`yyyy-MM-dd`). Journey logs are pointed at the date first, while the old
  // keys still exist, then the days with food are re-keyed and every legacy
  // entry is deleted.
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

    // 2. Re-key days. Days without any food are dropped, even if they hold
    //    goals or activity: under the new rules they would never have been
    //    stored. When several legacy days share a date, the first one holding
    //    food wins.
    final chosen = <String, int>{};
    for (final key in legacyKeys) {
      final day = dayBox.get(key)!;
      if (!_hasFood(day)) continue;
      chosen.putIfAbsent(keyOf(day), () => key);
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
