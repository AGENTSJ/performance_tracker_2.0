import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/advice.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';
import 'package:permission_handler/permission_handler.dart';

class DataService {
  var workService = locator<WorkoutService>();
  var foodService = locator<FoodService>();
  var dayService = locator<DayService>();
  var userService = locator<UserService>();
  var routService = locator<RoutineService>();
  var jourService = locator<JourneyService>();
  var reportService = locator<ReportService>();
  var trainerAgentService = locator<TrainerAgentService>();
  var advService = locator<AdviceService>();

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
        for (var j = 0; j < reps.length; j++) {
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
      var workout = Workout(
        name: name,
        sets: sets,
        enabled: true,
        desc: desc,
        volumes: [],
      );
      await workService.addWorkout(workout);
    }
  }

  DateTime getDateFromString(String date) {
    List<String> splited = date.split('-');
    var day = int.parse(splited[0]);
    var month = int.parse(splited[1]);
    var year = int.parse(splited[2]);
    DateTime dateObj = DateTime(year, month, day);
    return dateObj;
  }

  exportData() async {
    AppData appData = AppData(
      foods: foodService.getAllFoods(),
      days: dayService.getAllDays(),
      users: userService.getAllUser(),
      routines: routService.getAllRoutines(),
      workouts: workService.getAllWorkouts(),
      journeys: jourService.getAllJourney(),
      advices: advService.fetchAllAdvices(),
      conversations: [await trainerAgentService.getOlderChat()],
      reports: reportService.fetchAllReports(),
    );
    var jsonData = appData.toJson();
    await saveJsonToFile(jsonData, "PerformanceTracker");
  }
}

class AppData {
  List<Food> foods;
  List<Day> days;
  List<User> users;
  List<Routine> routines;
  List<Workout> workouts;
  List<Journey> journeys;
  List<AdviceSet> advices;
  List<AiChatContent> conversations;
  List<Report> reports;

  AppData({
    required this.foods,
    required this.days,
    required this.users,
    required this.routines,
    required this.workouts,
    required this.journeys,
    required this.advices,
    required this.conversations,
    required this.reports,
  });

  Map<String, dynamic> toJson() {
    return {
      "foods": foods.map((food) => food.toJson()).toList(),
      "days": days.map((day) => day.toJson()).toList(),
      "users": users.map((user) => user.toJson()).toList(),
      "routines": routines.map((routine) => routine.toJson()).toList(),
      "workouts": workouts.map((workout) => workout.toJson()).toList(),
      "journeys": journeys.map((journey) => journey.toJson()).toList(),
      "advices": advices.map((advice) => advice.toJson()).toList(),
      "conversations": conversations.map((conv) => conv.toJson()).toList(),
      "reports": reports.map((report) => report.toJson()).toList(),
    };
  }

  factory AppData.fromJson(Map<String, dynamic> map) {
    return AppData(
      foods: (map['foods'] as List<dynamic>)
          .map((e) => Food.fromJson(e as Map<String, dynamic>))
          .toList(),
      days: (map['days'] as List<dynamic>)
          .map((e) => Day.fromJson(e as Map<String, dynamic>))
          .toList(),
      users: (map['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      routines: (map['routines'] as List<dynamic>)
          .map((e) => Routine.fromJson(e as Map<String, dynamic>))
          .toList(),
      workouts: (map['workouts'] as List<dynamic>)
          .map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList(),
      journeys: (map['journeys'] as List<dynamic>)
          .map((e) => Journey.fromJson(e as Map<String, dynamic>))
          .toList(),
      advices: (map['advices'] as List<dynamic>)
          .map((e) => AdviceSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      conversations: (map['conversations'] as List<dynamic>)
          .map((e) => AiChatContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      reports: (map['reports'] as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

Future<void> saveJsonToFile(Map<String, dynamic> data, String fileName) async {
  // Request storage permission
  var status = await Permission.storage.request();
  if (!status.isGranted) {
    print('Permission denied');
    return;
  }

  // Convert Map to JSON string
  String jsonString = jsonEncode(data);

  // Get download directory (external for Android)
  Directory? directory = await getExternalStorageDirectory();
  if (directory == null) {
    print('Could not get directory');
    return;
  }

  // Create full path
  String filePath = '${directory.path}/$fileName.json';
  File file = File(filePath);

  // Write to file
  await file.writeAsString(jsonString);

  print('✅ JSON saved to: $filePath');
}
