import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Workout/models/fatigue.model.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/src/features/Workout/repositories/fatigue.repository.dart';
import 'package:performance_tracker/src/features/Workout/repositories/routine.repository.dart';

/// Muscle fatigue, calculated from the track entries and their fatigue
/// records.
///
/// Nothing calculated is stored. Each tracked set has one [FatigueEntry]
/// (the fatigue it added to each muscle), stored under the set's track entry
/// id. The fatigue before a set is the sum of the records of the sets tracked
/// earlier that day, and a day's fatigue is the sum of all of that day's
/// records. The track entries decide which sets exist and when they happened,
/// so a record left behind by a removed entry is never counted.
class FatigueService {
  final _repo = locator<FatigueRepository>();
  final _routineRepo = locator<RoutineRepository>();
  final _commonService = locator<CommonService>();

  // ---------------------------------------------------------------------------
  // Records
  // ---------------------------------------------------------------------------

  /// Stores the fatigue [entry] adds, taken from [workout]'s current volumes.
  Future<void> record(TrackEntry entry, Workout workout) async {
    await _repo.put(_recordFor(entry, workout));
  }

  /// Removes the fatigue records of [entries].
  Future<void> remove(Iterable<TrackEntry> entries) async {
    await _repo.deleteAll(entries.map((e) => e.id));
  }

  /// Every stored record, for backups.
  List<FatigueEntry> getAllRecords() => _repo.getAll();

  /// Replaces every record with [records] (from a backup), then fills in any
  /// track entry of [workouts] the backup had no record for.
  Future<void> restore(
    List<FatigueEntry> records,
    List<Workout> workouts,
  ) async {
    await _repo.clearAll();
    await _repo.putAll(records);
    await ensureRecords(workouts);
  }

  /// Creates a record, from the workout's current volumes, for every track
  /// entry that has none. Defaults to every stored workout.
  Future<void> ensureRecords([List<Workout>? workouts]) async {
    final existing = _repo.ids.toSet();
    final missing = <FatigueEntry>[];
    for (final workout in workouts ?? _routineRepo.getAllWorkouts()) {
      for (final set in workout.sets) {
        for (final entry in set.history) {
          if (!existing.contains(entry.id)) {
            missing.add(_recordFor(entry, workout));
          }
        }
      }
    }
    if (missing.isNotEmpty) await _repo.putAll(missing);
  }

  /// Deletes records whose track entry no longer exists.
  Future<void> pruneOrphans() async {
    final live = <String>{
      for (final workout in _routineRepo.getAllWorkouts())
        for (final set in workout.sets)
          for (final entry in set.history) entry.id,
    };
    final orphans = _repo.ids.where((id) => !live.contains(id)).toList();
    if (orphans.isNotEmpty) await _repo.deleteAll(orphans);
  }

  FatigueEntry _recordFor(TrackEntry entry, Workout workout) => FatigueEntry(
    trackEntryId: entry.id,
    muscleFatigue: volumesOf(workout),
  );

  // ---------------------------------------------------------------------------
  // Calculation
  // ---------------------------------------------------------------------------

  /// A calculator over the stored workouts and records. Build one and reuse
  /// it when calculating for many entries (a chart, a report).
  FatigueCalculator calculator() => FatigueCalculator(
    _routineRepo.getAllWorkouts(),
    _repo.getAllById(),
    _commonService.getDateKey,
  );

  /// Fatigue accumulated on [date] (defaults to today), by muscle.
  Map<String, double> getDailyFatigue({DateTime? date}) {
    return calculator().dailyFatigue(date ?? DateTime.now());
  }

  /// Past days with fatigue (excluding today), most recent first. Pass
  /// [limit] to cap how many days are returned.
  List<DailyFatigue> getPastFatigueDays({int? limit}) {
    return calculator().pastDays(before: DateTime.now(), limit: limit);
  }

  /// Fatigue context for [entry]: see [FatigueCalculator.contextFor].
  double contextFor(TrackEntry entry, Workout workout) {
    return calculator().contextFor(entry, workout);
  }
}

/// [workout]'s muscle volumes as muscle name -> volume.
Map<String, double> volumesOf(Workout workout) {
  final volumes = <String, double>{};
  for (final vol in workout.volumes) {
    volumes[vol.muscleName] = (volumes[vol.muscleName] ?? 0) + vol.volume;
  }
  return volumes;
}

class _Tracked {
  final TrackEntry entry;
  final Workout workout;
  _Tracked(this.entry, this.workout);
}

/// Calculates fatigue from a snapshot of workouts and fatigue records.
/// Indexes every track entry by day once, so each calculation only looks at
/// one day's entries.
class FatigueCalculator {
  final Map<String, FatigueEntry> _records;
  final String Function(DateTime) _dateKey;
  final Map<String, List<_Tracked>> _byDay = {};

  FatigueCalculator(
    Iterable<Workout> workouts,
    this._records,
    this._dateKey,
  ) {
    for (final workout in workouts) {
      for (final set in workout.sets) {
        for (final entry in set.history) {
          _byDay
              .putIfAbsent(_dateKey(entry.entryDate), () => [])
              .add(_Tracked(entry, workout));
        }
      }
    }
    for (final day in _byDay.values) {
      day.sort((a, b) => a.entry.entryDate.compareTo(b.entry.entryDate));
    }
  }

  /// The fatigue [entry] added. Falls back to [workout]'s current volumes
  /// when the entry has no record.
  Map<String, double> fatigueOf(TrackEntry entry, Workout workout) {
    return _records[entry.id]?.muscleFatigue ?? volumesOf(workout);
  }

  /// Fatigue accumulated on [entry]'s day before it was tracked, by muscle.
  Map<String, double> fatigueBefore(TrackEntry entry) {
    final total = <String, double>{};
    for (final tracked in _byDay[_dateKey(entry.entryDate)] ?? const []) {
      if (!tracked.entry.entryDate.isBefore(entry.entryDate)) break;
      if (tracked.entry.id == entry.id) continue;
      _addInto(total, fatigueOf(tracked.entry, tracked.workout));
    }
    return total;
  }

  /// How fatigued the muscles [entry] works were when it was tracked: for each
  /// muscle, the fatigue accumulated before it times the fatigue it adds.
  double contextFor(TrackEntry entry, Workout workout) {
    final before = fatigueBefore(entry);
    var context = 0.0;
    fatigueOf(entry, workout).forEach((muscle, volume) {
      context += (before[muscle] ?? 0) * volume;
    });
    return context;
  }

  /// Fatigue accumulated on [date], by muscle.
  Map<String, double> dailyFatigue(DateTime date) {
    final total = <String, double>{};
    for (final tracked in _byDay[_dateKey(date)] ?? const []) {
      _addInto(total, fatigueOf(tracked.entry, tracked.workout));
    }
    return total;
  }

  /// Days before [before]'s day that have fatigue, most recent first.
  List<DailyFatigue> pastDays({required DateTime before, int? limit}) {
    final excludedKey = _dateKey(before);
    final days = <DailyFatigue>[];
    for (final entry in _byDay.entries) {
      if (entry.key == excludedKey || entry.value.isEmpty) continue;
      final date = entry.value.first.entry.entryDate;
      final fatigue = dailyFatigue(date);
      if (fatigue.isEmpty) continue;
      days.add(
        DailyFatigue(
          date: DateTime(date.year, date.month, date.day),
          muscleFatigue: fatigue,
        ),
      );
    }
    days.removeWhere((d) => !d.date.isBefore(before));
    days.sort((a, b) => b.date.compareTo(a.date));
    if (limit != null && days.length > limit) return days.sublist(0, limit);
    return days;
  }

  static void _addInto(Map<String, double> total, Map<String, double> add) {
    add.forEach((muscle, value) {
      total[muscle] = (total[muscle] ?? 0) + value;
    });
  }
}
