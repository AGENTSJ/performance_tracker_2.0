import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/advice.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/services/workout.service.dart';

class CoachServerMcp {
  final adviceService = locator<AdviceService>();
  final workoutService = locator<WorkoutService>();
  final routineService = locator<RoutineService>();

  Future<void> updateAdviceSets({List<AdviceSet>? advices}) async {
    if (advices == null) return;

    await adviceService.clearAllAdviceSet();
    for (var advSet in advices) {
      var set = AdviceSet(
        advices: [],
        lastUpdated: DateTime.now(),
        title: advSet.title,
        type: advSet.type,
      );
      for (var adv in advSet.advices) {
        var newAdv = Advice(
          adviceDesc: adv.adviceDesc,
          conditions: adv.conditions,
          title: adv.title,
          date: DateTime.now(),
        );
        set.advices.add(newAdv);
      }
      adviceService.createAdvice(advSet);
    }
  }

  Future<void> addRoutine({required String routineName, required String routineDesc,List<Workout>newWorkouts=const [], List<int> workoutIds=const []})async
  {
    var routineId = await routineService.addRoutine(Routine(name: routineName, workoutsIds: [], createdAt: DateTime.now(), isCustom: true, desc: routineDesc));
    await updateRoutine(routineKey: routineId,newWorkouts: newWorkouts,workoutIds: workoutIds);
  }
  
  Future<void> updateRoutine({required int routineKey, List<Workout>newWorkouts=const [], List<int> workoutIds=const []})async
  {
    for (var workout in newWorkouts) {
      var work = await workoutService.addWorkout(workout);
      workoutIds.add(work!.key);
    }
    var routine = await routineService.getRoutineById(routineKey);
    routine!.workoutsIds = workoutIds;
    await routineService.updateRoutine(routine);
  }

  Future<void> addWorkout(Workout workout)async
  {
    await workoutService.addWorkout(workout);
  }

  Future<void> updateWorkout(int id, Workout workout)async
  {
    await workoutService.updateWorkout(id: id, workout);
  }

  Future<String> getKnowledgeBase() async {
    var routines = routineService.getAllCustomRoutines();
    var routineRepresentation = "";
    for (var rout in routines) {
      routineRepresentation += await PromptInformation.getRoutineInformation(
        rout,
      );
    }
    var workouts = workoutService.getAllWorkouts();
    var allWorkoutInfo = "";
    for (var workout in workouts) {
      allWorkoutInfo += "${PromptInformation.getWorkoutInformation(workout)}\n";
    }
    String adviceKnowledge =
    '''
    Volume is an indicator that is same as workout volume but disregard the rep aspect means the volume is calculated based on how much a muscle is affected or impacted by a certain workout ranging between 0 and 1 for an workout for an muscle group
    User has routines :\n
    $routineRepresentation
    all Workouts user has that may or may not be in routines :\n
    $allWorkoutInfo
    There are mainly 3 types of advice set this platform provides 
    1 on going advices 
    2 not worked
    3 worked 
    advices : ''';
    var adviceSets = adviceService.fetchAllAdvices();
    for (var advSet in adviceSets) {
      String setRep = advSet.toJson().toString();
      adviceKnowledge += setRep;
    }
    return adviceKnowledge;
  }
}

class PromptInformation {
  static final _routineService = locator<RoutineService>();

  static Future<String> getRoutineInformation(Routine routine) async {
    var volumes = await _routineService.getRoutinesVolume(routine);
    var workouts = await _routineService.getRoutinesWorkouts(routine);
    var routineRep =
        "Routine Id:${routine.key}\n Routine name : ${routine.name}\n";

    routineRep += "Volume present in the routine : \n";
    for (var vol in volumes) {
      routineRep += "\t${vol.muscleName} ${vol.volume}\n";
    }
    routineRep += "Workouts inside this routine\n";
    for (var work in workouts) {
      var workoutRep = PromptInformation.getWorkoutInformation(work);
      routineRep += workoutRep;
    }
    return routineRep;
  }

  static String getWorkoutInformation(Workout workout) {
    var workoutRep =
        "\tWorkout Id : ${workout.key}\n Workout name : ${workout.name}";
    var workVolume = workout.volumes;
    workoutRep += "\t\tWorkout contributes volume : \n";
    for (var vol in workVolume) {
      workoutRep += "\t${vol.muscleName} ${vol.volume}\n";
    }
    workoutRep += "\t\tWorkout has sets : \n";
    for (var set in workout.sets) {
      workoutRep += "\tSet kg ${set.value} is enabled ${set.enabled}\n";
    }
    return workoutRep;
  }
}
