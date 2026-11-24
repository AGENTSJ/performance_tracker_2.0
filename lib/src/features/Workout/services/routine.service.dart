import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/src/features/Workout/repositories/routine.repository.dart';
import 'package:performance_tracker/src/features/Workout/services/workout.service.dart';
class SummaryDTO<T> {
  DateTime? recentUpdate;
  T data;
  SummaryDTO({required this.recentUpdate, required this.data});
}

class RoutineService {
  final _routineRepo = locator<RoutineRepository>();
  final _workService = locator<WorkoutService>();
  final _commonService = locator<CommonService>();

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

  /// Returns the stored auto routine for [date], or a new unsaved one.
  Routine getDayRoutine(DateTime date) {
    final dateKey = _commonService.getDateKey(date);
    return _routineRepo.getRoutineByDateKey(dateKey) ??
        Routine(
          name: _commonService.getDateString(date),
          workoutsIds: [],
          createdAt: DateTime.now(),
          isCustom: false,
          desc: '',
          dateKey: dateKey,
        );
  }

  List<Routine> getAllAutoRoutines() {
    return _routineRepo
        .getAllRoutines()
        .where((rout) => rout.isCustom == false)
        .toList();
  }

  /// Saves [routine]. An auto routine reaches storage only once a workout is
  /// added to it; after that every update is saved, even if all the workouts
  /// are removed again.
  updateRoutine(Routine routine) async {
    final dateKey = routine.dateKey;
    if (dateKey != null &&
        !_routineRepo.isRoutineStored(dateKey) &&
        routine.workoutsIds.isEmpty) {
      return;
    }
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

  Future<List<WorkoutVolume>> getRoutinesVolume(Routine routine)async {
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

  List<Routine> getAllRoutines()
  {
    return _routineRepo.getAllRoutines();
  }
  clearAll()async
  {
    await _routineRepo.clearAll();
  }
}
