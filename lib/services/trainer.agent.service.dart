import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
// import 'package:performance_tracker/services/workout.service.dart';

class TrainerAgentService {
  final _aiService = locator<AiService>();
  // final _workoutService = locator<WorkoutService>();
  final _routineService = locator<RoutineService>();
  final _commonService = locator<CommonService>();

  Future<String> getPerformanceSummary(DateTime? summaryFromDate) async {
    var routines = _routineService.getAllCustomRoutines();
    var summary = "";
    List<Future<String>> futures = [];
    for (var rout in routines) {
        futures.add(
          _generateRoutineSummary(rout, null)
        );
    }
    var results = await Future.wait(futures);
    for (var res in results) {
      summary+="$res \n\n";
    }
    print("whole summary started");
    var res = await _aiService.getResponse(summary, "You are a physical trainer user has ${routines.length} routines Identify potential improvements user can make to strength gains precise and concise your response must be concise but it should consider all the improvements user should make line by line");
    print("whole summary ended");
    return res.message;
  }

  Future<String> _generateWorkoutSummary(Workout workout, DateTime? summaryFromDate) async {
      print("${workout.name} started");
    var EnabledSet = workout.sets.where((set) => set.enabled);
    var totalEnabledSet = EnabledSet.length;
    String workRep =
        '''Workout name : ${workout.name}\nFrom Total of $totalEnabledSet sets User gets an total volume of :\n''';
    for (var vol in workout.volumes) {
      workRep += "\t${vol.muscleName} ${vol.volume * totalEnabledSet}\n";
    }
    workRep += "Sets descriptions :\n";
    var i = 1;
    for (var set in EnabledSet) {
      workRep += _summarizeSetPerformance(set, summaryFromDate, i);
      i++;
    }
    var resp = await _aiService.getResponse(
      workRep,
      "You are an workout observer your role is to analyze the prompt that consing of description about workout and provide valuable insights on each sets your response should be same structure as prompt but b need tot summarize the set the summary must include average interval in days that user did the sets the user performance is stagnant or strengthen or got weak the data is critical to guide user",
    );
    print("${workout.name} finished");
    return resp.message;
  }

  String _summarizeSetPerformance(
    WorkSet set,
    DateTime? summaryFromDate,
    int index,
  ) {
    String setSummary = "Set $index ${set.value}kg:\n";
    bool beforeAdded = false;
    bool afterAdded = false;

    List<TrackEntry> contextEntries = [];
    if (set.history.length > 5) {
      contextEntries = set.history.sublist(set.history.length - 5);
    } else {
      contextEntries = set.history;
    }
    for (var entry in contextEntries) {
      if ((summaryFromDate == null ||
              entry.entryDate.isBefore(summaryFromDate)) &&
          !beforeAdded) {
        setSummary += "\t Before the current advice\n";
        beforeAdded = true;
      }
      if ((summaryFromDate != null &&
              entry.entryDate.isAfter(summaryFromDate)) &&
          !afterAdded) {
        setSummary += "\tAfter the advice\n";
        afterAdded = true;
      }
      setSummary +=
          "\t\t\t${_commonService.getDateString(entry.entryDate)} Reps : ${entry.value}\n";
    }
    return setSummary;
  }

  Future<String> _generateRoutineSummary(Routine routine, DateTime? summaryFromDate) async {
    var routineSummary = "Routine name : ${routine.name}\nVolumes in the Routine : \n";
    var workouts = await _routineService.getRoutinesWorkouts(routine);
    var volumes = await _routineService.getRoutinesVolume(routine);
    List<Future<String>> futures = [

    ];
    for (var vol in volumes) {
      routineSummary += "\t${vol.muscleName} ${vol.volume}\n";
    }
    for (var work in workouts) {
      futures.add(
          _generateWorkoutSummary(work, summaryFromDate)
      );
    }
    final results = await Future.wait(futures);
    for (var res in results) {
      routineSummary+="${res}\n\n";
    }
    print("${routine.name} summary started");
    // return routineSummary;
    var resp = await _aiService.getResponse(routineSummary, "Summaries this routine and draw out important observation",modelType: Models.Pro);
    print("${routine.name} summary finished");
    return resp.message;
    
  }
}