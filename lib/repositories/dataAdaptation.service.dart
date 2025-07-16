import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
// import 'package:performance_tracker/repositories/data.dart';
import 'package:performance_tracker/services/workout.service.dart';

class DataService {
  var workService = locator<WorkoutService>();
  restoreDataFromBackup(oldData) async {
    List<dynamic> oldWorkouts =
        oldData["objectStore"]?["data"] as List<dynamic>;
    for (var work in oldWorkouts) {
      var name = work["workname"];
      List<WorkSet> sets = [];
      var desc = work["desc"];
      var kgList = work["kg"];
      for (var i = 0; i < kgList.length; i++) {
        var kg = kgList[i];
        var max = work["max"][i];
        List<TrackEntry> history = [];
        var reps = work["rep"][i];
        var dates = work["date"][i];
        for(var j = 0 ;j<reps.length;j++)
        {
          var rep = reps[j];
          var entryDate = getDateFromString(dates[j]);
          TrackEntry tEntry = TrackEntry(entryDate: entryDate, value: rep);
          history.add(tEntry);
        }
        var workSet = WorkSet(
          value: kg.toDouble(),
          history: history,
          pr: max,
          enabled: true,
        );
        sets.add(workSet);
      }
      var workout = Workout(name: name, sets: sets, enabled: true, desc: desc);
      await workService.addWorkout(workout);
    }
    print("done");
  }

  DateTime getDateFromString(String date)
  {
    List<String> splited = date.split('-');
    var day = int.parse(splited[0]);
    var month = int.parse(splited[1]);
    var year = int.parse(splited[2]);
    DateTime dateObj = DateTime(year,month,day);
    return dateObj;
  }
}
