import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/repositories/routine.repository.dart';
import 'package:performance_tracker/services/workout.service.dart';

class RoutineService {
  final _routineRepo = locator<RoutineRepository>();
  final _workService = locator<WorkoutService>();

  Future<int> addRoutine(Routine routine) async {
    var routineSearch = _routineRepo.getRoutineByName(routine.name);
    if (routineSearch != null) {
      return -1;
    }
    return _routineRepo.addRoutine(routine);
  }

  Future<Routine?> getRoutineById(int id) async {
    return _routineRepo.getRoutineById(id);
  }

  List<Routine> getAllRoutines() {
    return _routineRepo
        .getAllRoutines()
        .where((rout) => rout.isCustom == false)
        .toList();
  }

  updateRoutine(Routine routine) async {
    await _routineRepo.updateRoutine(routine);
  }

  Future<List<Workout>> getRoutinesWorkouts(Routine routine) async {
    List<Workout> workouts = [];
    bool invalidKeysFound = false;
    List<int> invalidKeys = [];
    for (var workId in routine.workoutsIds) {
      var work = await _workService.getWorkOutById(workId);
      if (work != null) {
        workouts.add(work);
      } else {
        invalidKeysFound = true;
        invalidKeys.add(workId);
      }
    }
    if (invalidKeysFound == true) {
      for (var invKey in invalidKeys) {
        routine.workoutsIds.remove(invKey);
      }
      await updateRoutine(routine);
    }
    return workouts;
  }

  removeRoutine(Routine routine) async {
    return await _routineRepo.removeRoutine(routine);
  }

  List<Routine> getAllCustomRoutines() {
    var all = _routineRepo.getAllRoutines().toList();
    return all.where((rout) => rout.isCustom == true).toList();
  }

  getRoutinesVolume(Routine routine)async {
    List<WorkoutVolume> volumes = [];
    var workouts = await getRoutinesWorkouts(routine);
    for (var work in workouts) {
      for (var vol in work.volumes) {
        var presentVol = _getVolumeByName(vol.muscleName,volumes);
        if (presentVol == null) {
          vol = WorkoutVolume(muscleName: vol.muscleName, volume: vol.volume);
          vol.volume =
              vol.volume * work.sets.where((set) => set.enabled).length;
          volumes.add(vol);
        } else {
          presentVol.volume +=
              vol.volume * work.sets.where((set) => set.enabled).length;
        }
      }
    }
    return volumes;
  }
  WorkoutVolume? _getVolumeByName(String name ,List<WorkoutVolume> volumes) {
    for (var vol in volumes) {
      if (vol.muscleName == name) {
        return vol;
      }
    }
    return null;
  }
}
