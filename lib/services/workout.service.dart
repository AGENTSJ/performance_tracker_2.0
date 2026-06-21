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

  Future<void> updateWorkout(Workout workout,{int id = -1}) async {
    return routineRepo.updateWorkout(id==-1? workout.key:id, workout);
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

  Future<void> removeWorkout(Workout workout) async
  {
    await routineRepo.removeWorkout(workout);
  }

  Future<void> trackRep(Workout workout , WorkSet set ,int repVal) async
  {
    var last = set.history.lastOrNull;
    if(last==null || (commonService.getDateString(last.entryDate)!=commonService.getDateString(DateTime.now())))
    {
      // First time this set is recorded today: capture the fatigue context from
      // the daily fatigue state BEFORE this set contributes to it.
      var fatigueContext = fatigueService.calculateFatigueContext(workout);
      last = TrackEntry(entryDate: DateTime.now(), value: repVal, fatigueContext: fatigueContext);
      set.history.add(last);
      // Apply this set's muscle volumes to the daily fatigue map AFTER storing
      // the entry, so it accumulates only once per set per day.
      await fatigueService.accumulateFatigue(workout);
    }
    else
    {
      last.value = repVal;
    }
    if(set.pr <=last.value)
    {
      set.pr = last.value;
    }
    await updateWorkout(workout);
  }

  clearAll()async
  {
    await routineRepo.clearAllWorkouts();
  }
}
