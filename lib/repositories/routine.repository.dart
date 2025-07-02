import 'package:hive/hive.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/routine.model.dart';

class RoutineRepository {
  final routineBox = Hive.box<Routine>(Collections.routines.value);
  final workoutBox = Hive.box<Workout>(Collections.workouts.value);

  
  Routine? getRoutineByName(String name)
  {
    var routine = routineBox.values.firstWhere(
      (routine) => routine.name == name,
    );
    return routine;
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



  Future<Workout?> getWorkoutById(int id) async
  {
    return  workoutBox.get(id);
  }

  // add workout 
  // remove workout workout 
}