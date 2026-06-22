import 'dart:math';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/repositories/routine.repository.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/fatigue.service.dart';

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

  Future<void> removeWorkout(Workout workout) async {
    await routineRepo.removeWorkout(workout);
  }

  Future<void> trackRep(Workout workout, WorkSet set, int repVal) async {
    var last = set.history.lastOrNull;
    if (last == null ||
        (commonService.getDateString(last.entryDate) !=
            commonService.getDateString(DateTime.now()))) {
      // First time this set is recorded today: capture the fatigue context from
      // the daily fatigue state BEFORE this set contributes to it.
      var fatigueContext = fatigueService.calculateFatigueContext(workout);
      last = TrackEntry(
        entryDate: DateTime.now(),
        value: repVal,
        fatigueContext: fatigueContext,
      );
      set.history.add(last);
      // Apply this set's muscle volumes to the daily fatigue map AFTER storing
      // the entry, so it accumulates only once per set per day.
      await fatigueService.accumulateFatigue(workout);
    } else {
      last.value = repVal;
    }
    if (set.pr <= last.value) {
      set.pr = last.value;
    }
    await updateWorkout(workout);
  }

  clearAll() async {
    await routineRepo.clearAllWorkouts();
  }

  WorkSetProgression getWorkSetProgression(Workout workout, List<TrackEntry> entries) {
    final List<double> reps = [];
    final totalEntries = entries.length;
    var sumOfReps = 0.0;
    var sumOfCounts = 0.0;
    for (var i = 0; i < totalEntries; i++) {
      final entry = entries[i];
      final adjustedRep = workout.getFatigueAdjustedReps(
        entry.fatigueContext,
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
      final rep = reps[i-1];
      num += ((i - meanX) * (rep - meanY));
      deno += pow(i - meanX, 2);
    }

    final slope = (num / deno);
    final intercept = meanY - (slope*meanX);

    // Confidence (R squared)
    var rNum = 0.0;
    var rDeno = 0.0;

    for (var i = 1; i < totalEntries + 1; i++) {
      final rep = reps[i-1];
      final yIntercept = (slope*i) + intercept;
      rNum += pow(rep - yIntercept, 2);
      rDeno += pow(rep - meanY, 2);
    }

    final confidence = 1 - (rNum / rDeno);

    if(slope > 0.05 && confidence >0.5)
    {
      return WorkSetProgression.progressing;
    }
    if(slope < -0.05 && confidence > 0.5)
    {
      return WorkSetProgression.regressing;
    }
    return WorkSetProgression.stale;
  }

}

enum WorkSetProgression {
  progressing("Progressing"),
  stale("Stale"),
  regressing("Regressing");

  final String value;
  const WorkSetProgression(this.value);
}
