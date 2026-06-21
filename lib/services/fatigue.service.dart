import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/fatigue.model.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/repositories/fatigue.repository.dart';

/// Captures and tracks accumulated muscle fatigue across the workouts a user
/// performs within a single day.
///
/// The fatigue map ([Map] of muscle name -> accumulated fatigue) is shared
/// across all workouts on the same day and resets when a new day begins (a new
/// day simply has no stored record yet).
///
/// Typical flow when a set is recorded:
///   1. [calculateFatigueContext] using the fatigue state BEFORE the set.
///   2. Store that context on the rep entry.
///   3. [accumulateFatigue] to apply the exercise volumes to the daily map.
class FatigueService {
  final _repo = locator<FatigueRepository>();

  /// Lower/upper bounds the fatigue context is clamped to.
  // static const double fatigueContextMin = 0;
  // static const double fatigueContextMax = 2;

  String _dateKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

  /// Parses a stored [dateKey] ("year-month-day") back into a [DateTime].
  DateTime dateFromKey(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Returns the accumulated fatigue map for [date] (defaults to today).
  /// Returns an empty map when no fatigue has accumulated yet for that day.
  Map<String, double> getDailyFatigue({DateTime? date}) {
    date ??= DateTime.now();
    final day = _repo.getByDateKey(_dateKey(date));
    return day?.muscleFatigue ?? {};
  }

  /// Past daily fatigue records (excluding today), most recent first.
  /// Pass [limit] to cap how many days are returned.
  List<FatigueDay> getPastFatigueDays({int? limit}) {
    final todayKey = _dateKey(DateTime.now());
    final days = _repo
        .getAll()
        .where((d) => d.dateKey != todayKey && d.muscleFatigue.isNotEmpty)
        .toList();
    days.sort((a, b) => dateFromKey(b.dateKey).compareTo(dateFromKey(a.dateKey)));
    if (limit != null && days.length > limit) {
      return days.sublist(0, limit);
    }
    return days;
  }

  /// Calculates the fatigue context for performing [workout] given the fatigue
  /// state BEFORE this set is applied. The set must not contribute to its own
  /// fatigue context, so this must be called before [accumulateFatigue].
  ///
  /// For each muscle the exercise targets: muscleFatigue x exerciseVolume.
  /// The results are summed and normalized via clamp(0, 2).
  double calculateFatigueContext(Workout workout, {DateTime? date}) {
    final fatigue = getDailyFatigue(date: date);
    double raw = 0;
    for (final vol in workout.volumes) {
      raw += (fatigue[vol.muscleName] ?? 0) * vol.volume;
    }
    return raw;
  }

  /// Applies [workout]'s muscle volumes to the daily fatigue map, accumulating
  /// fatigue. Call this AFTER the rep entry has been stored so the set does not
  /// contribute to its own fatigue context.
  Future<void> accumulateFatigue(Workout workout, {DateTime? date}) async {
    date ??= DateTime.now();
    final key = _dateKey(date);
    final day =
        _repo.getByDateKey(key) ??
        FatigueDay(dateKey: key, muscleFatigue: {});
    for (final vol in workout.volumes) {
      day.muscleFatigue[vol.muscleName] =
          (day.muscleFatigue[vol.muscleName] ?? 0) + vol.volume;
    }
    await _repo.upsert(day);
  }
}
