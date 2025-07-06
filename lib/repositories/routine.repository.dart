import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/routine.model.dart';

class RoutineRepository {
  final routineBox = Hive.box<Routine>(Collections.routines.value);
  final workoutBox = Hive.box<Workout>(Collections.workouts.value);

  
  Routine? getRoutineByName(String name)
  {
    for (var routine in routineBox.values) {
      if(routine.name==name)
      {
        return routine;
      }
    } 
    return null;
  }
  updateRoutine(Routine routine)async
  {
    await routineBox.put(routine.key, routine);
  }
  Routine? getRoutineById(int id)
  {
    return routineBox.get(id);
  }

  Future<int> addRoutine(Routine routine)async
  {
    var res  = getRoutineByName(routine.name);
    if(res!=null)
    {
      return -1;
    }
    return await routineBox.add(routine);
  }

  removeRoutine(Routine routine) async
  {
    return await routineBox.delete(routine.key);
  }

  List<Routine> getAllRoutines()
  {
    return routineBox.values.toList();
  }

  Future<Workout?> getWorkoutById(int id) async
  {
    return  workoutBox.get(id);
  }

  Future<int> addWorkout(Workout workout)async
  {
    return await workoutBox.add(workout);
  }

  Future<void> removeWorkout(Workout workout) async
  {
    return await workoutBox.delete(workout.key);
  }

  List<Workout> getWorkoutsByName(String name)
  {
    var workouts = workoutBox.values;
    name = name.toLowerCase();
    var filtered = workouts.where((work)=>work.name.toLowerCase().startsWith(name));
    return filtered.toList();
  }

  List<Workout> getAllWorkouts()
  {
    return workoutBox.values.toList();
  }

  Future<void> updateWorkout(int key,Workout workout)async
  {
    return await workoutBox.put(key, workout);
  }
}