import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
// import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
// import 'package:performance_tracker/services/workout.service.dart';

class TrainerAgentService {
  // final _aiService = locator<AiService>();
  // final _workoutService = locator<WorkoutService>();
  final _routineService = locator<RoutineService>();
  final _commonService = locator<CommonService>();

  analyzePerformance() {
    // var res = _generateRoutineSummary();
  }

  _generateWorkoutSummary(Workout workout) async {
    String workRep = '''Workout name : ${workout.name}\nSets :\n''';
    for (var set in workout.sets) {
      if (set.enabled) {
        String setRep = '''Weight ${set.value}kg ,\nUser has done :\n''';
        for (var histPoint in _getContextSetDataEntry(set.history)) {
          setRep +=
              "${histPoint.value}reps on ${_commonService.getDateString(histPoint.entryDate)}\n";
        }
        workRep += setRep;
      }
    }
    workRep += "User journal :${workout.desc}";
    return workRep;
  }

  _getContextSetDataEntry(List<TrackEntry> history) {
    if (history.length > 15) {
      return history.sublist(history.length - 15);
    } else {
      return history;
    }
  }

  _generateRoutineSummary() async {
    var routines = _routineService.getAllCustomRoutines();

    for (var routine in routines) {
      var workouts = await _routineService.getRoutinesWorkouts(routine);
      for (var work in workouts) {
        var resp = await _generateWorkoutSummary(work);
        return resp;
      }
      break;
    }
  }

  // _generateTrainingSummary() {}

  // _generateNutritionSummary() {}

  // _identifyProgressDeterminants() {}
}
