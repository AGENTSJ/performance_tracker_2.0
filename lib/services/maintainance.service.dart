import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/routine.service.dart';

class MaintainanceService {
  final _routineService = locator<RoutineService>();

  cleanUp()
  {
    _removeOldRoutines();
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