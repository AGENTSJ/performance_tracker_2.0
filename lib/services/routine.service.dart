import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/repositories/routine.repository.dart';
import 'package:performance_tracker/services/workout.service.dart';

class RoutineService {

  final _routineRepo = locator<RoutineRepository>();
  final _workService = locator<WorkoutService>();

  Future<int> addRoutine(Routine routine)
  {
    return _routineRepo.addRoutine(routine);
  }

  Future<Routine?> getRoutineById(int id) async
  {
    return _routineRepo.getRoutineById(id);
  }

  List<Routine> getAllRoutines()
  {
    return _routineRepo.getAllRoutines();
  }

  updateRoutine(Routine routine)async
  {
    await _routineRepo.updateRoutine(routine);
  }

  Future<List<Workout>> getRoutinesWorkouts(Routine routine) async
  {
    List<Workout> workouts = [];
    for (var workId in routine.workoutsIds) {
      var work = await _workService.getWorkOutById(workId);
      if(work!=null)
      {
        workouts.add(work);
      }
    }
    return workouts;
  }
  removeRoutine(Routine routine)async
  {
    return await _routineRepo.removeRoutine(routine);
  }
}