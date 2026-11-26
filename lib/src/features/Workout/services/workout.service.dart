import 'dart:math';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/src/features/Workout/repositories/routine.repository.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Workout/services/fatigue.service.dart';

class WorkoutService {
  var routineRepo = locator<RoutineRepository>();
  var commonService = locator<CommonService>();
  var fatigueService = locator<FatigueService>();

  Future<Workout?> getWorkOutById(int key) {
    return routineRepo.getWorkoutById(key);
  }

  List<Workout> getAllWorkouts() {
    return routineRepo.getAllWorkouts();
  }

  List<Workout> searchWorkoutByName(String name) {
    return routineRepo.getWorkoutsByName(name);
  }

  Future<void> updateWorkout(Workout workout, {int id = -1}) async {
    return routineRepo.updateWorkout(id == -1 ? workout.key : id, workout);
  }

  bool isWorkoutNameUnique(String name) {
    var workouts = routineRepo.getAllWorkouts();
    for (var work in workouts) {
      if (work.name == name) {
        return false;
      }
    }
    return true;
  }

  Future<Workout?> addWorkout(Workout workout) async {
    var isUnique = isWorkoutNameUnique(workout.name);
    if (!isUnique) {
      workout.name = "${workout.name} ${DateTime.now()}";
    }
    var key = await routineRepo.addWorkout(workout);
    return await getWorkOutById(key);
  }

  /// Removes [workout] along with the fatigue of every set tracked on it.
  Future<void> removeWorkout(Workout workout) async {
    await fatigueService.remove(
      workout.sets.expand((set) => set.history).toList(),
    );
    await routineRepo.removeWorkout(workout);
  }

  /// Removes [set] from [workout] along with the fatigue of its entries.
  Future<void> removeSet(Workout workout, WorkSet set) async {
    workout.sets.remove(set);
    await updateWorkout(workout);
    await fatigueService.remove(set.history);
  }

  Future<void> trackRep(Workout workout, WorkSet set, int repVal) async {
    var last = set.history.lastOrNull;
    TrackEntry? added;
    if (last == null ||
        (commonService.getDateString(last.entryDate) !=
            commonService.getDateString(DateTime.now()))) {
      // First time this set is recorded today.
      last = TrackEntry(entryDate: DateTime.now(), value: repVal);
      set.history.add(last);
      added = last;
    } else {
      last.value = repVal;
    }
    if (set.pr <= last.value) {
      set.pr = last.value;
    }
    await updateWorkout(workout);
    // Record the fatigue this set adds once per set per day; re-tracking the
    // same day only changes the reps, which don't affect fatigue.
    if (added != null) await fatigueService.record(added, workout);
  }

  /// Whether [set] already has an entry tracked for today.
  bool isTrackedToday(WorkSet set) {
    final last = set.history.lastOrNull;
    return last != null && isSameDay(last.entryDate, DateTime.now());
  }

  /// Removes today's tracked entry for [set] and its fatigue, and
  /// recalculates the set's PR from the remaining history. Fatigue of sets
  /// tracked after it is calculated, so it needs no update.
  Future<bool> clearTodayRep(Workout workout, WorkSet set) async {
    if (!isTrackedToday(set)) return false;
    final removed = set.history.removeLast();
    set.pr = set.history.fold<int>(0, (best, e) => max(best, e.value));
    await updateWorkout(workout);
    await fatigueService.remove([removed]);
    return true;
  }

  clearAll() async {
    await routineRepo.clearAllWorkouts();
  }

  WorkSetProgression getWorkSetProgression(
    Workout workout,
    List<TrackEntry> entries,
  ) {
    final List<double> reps = [];
    final totalEntries = entries.length;
    final fatigue = fatigueService.calculator();
    var sumOfReps = 0.0;
    var sumOfCounts = 0.0;
    for (var i = 0; i < totalEntries; i++) {
      final entry = entries[i];
      final adjustedRep = workout.getFatigueAdjustedReps(
        fatigue.contextFor(entry, workout),
        entry.value,
      );
      reps.add(adjustedRep);
      sumOfReps += adjustedRep;
      sumOfCounts += i + 1;
    }
    // Mean Y -> Mean of Reps
    // Mean X -> Mean of Count
    final meanY = (sumOfReps / totalEntries);
    final meanX = (sumOfCounts / totalEntries);

    // Slope calculation

    var num = 0.0;
    var deno = 0.0;
    for (var i = 1; i < totalEntries + 1; i++) {
      final rep = reps[i - 1];
      num += ((i - meanX) * (rep - meanY));
      deno += pow(i - meanX, 2);
    }

    final slope = (num / deno);
    final intercept = meanY - (slope * meanX);

    // Confidence (R squared)
    var rNum = 0.0;
    var rDeno = 0.0;

    for (var i = 1; i < totalEntries + 1; i++) {
      final rep = reps[i - 1];
      final yIntercept = (slope * i) + intercept;
      rNum += pow(rep - yIntercept, 2);
      rDeno += pow(rep - meanY, 2);
    }

    final confidence = 1 - (rNum / rDeno);

    if (slope > 0.05 && confidence > 0.5) {
      return WorkSetProgression.progressing;
    }
    if (slope < -0.05 && confidence > 0.5) {
      return WorkSetProgression.regressing;
    }
    return WorkSetProgression.stale;
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

enum WorkSetProgression {
  progressing("Progressing"),
  stale("Stale"),
  regressing("Regressing");

  final String value;
  const WorkSetProgression(this.value);
}
