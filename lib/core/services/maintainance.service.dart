import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Workout/services/fatigue.service.dart';
import 'package:performance_tracker/src/features/Workout/services/routine.service.dart';

class MaintainanceService {
  final _routineService = locator<RoutineService>();
  final _fatigueService = locator<FatigueService>();

  cleanUp()
  {
    _removeOldRoutines();
    // Fatigue records of entries removed without their record (e.g. a
    // workout replaced by the coach) are never counted, but take up space.
    _fatigueService.pruneOrphans();
  }
  _removeOldRoutines()async
  {
    const limit = 30;
    var today = DateTime.now();
    var filterDay = today.subtract(Duration(days: limit));
    var allRouts = _routineService.getAllAutoRoutines();
    for (var rout in allRouts) {
      if(rout.createdAt.isBefore(filterDay))
      {
        await _routineService.removeRoutine(rout);
      }
    }
  }
}