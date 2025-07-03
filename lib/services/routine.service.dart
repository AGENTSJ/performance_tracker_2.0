import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/repositories/routine.repository.dart';

class RoutineService {
  var routineRepo = locator<RoutineRepository>(); 
  Routine? getTodaysWorkout() { }
  
  Future<Workout?> getWorkOutById(int key) {
    return routineRepo.getWorkoutById(key);
  }

  List<Workout> getAllWorkouts(){
    return routineRepo.getAllWorkouts();
  }
  List<Workout> serachWorkoutByName(String name){
    return routineRepo.getWorkoutsByName(name);
  }
  Future<void> updateWorkout(Workout workout) async
  {
    return routineRepo.updateWorkout(workout.key, workout);
  }
  bool isWorkoutNameUnique(String name)
  {
    var workouts = routineRepo.getAllWorkouts();
    for (var work in workouts) {
      if(work.name==name)
      {
        return false;
      }
    }
    return true;
  }
  Future<Workout?> addWorkout(Workout workout) async
  {
    var isUnique = isWorkoutNameUnique(workout.name);
    if(!isUnique)
    {
      workout.name = "${workout.name} ${DateTime.now()}";
    }
    var key = await routineRepo.addWorkout(workout);
    return await getWorkOutById(key);
  } 
}