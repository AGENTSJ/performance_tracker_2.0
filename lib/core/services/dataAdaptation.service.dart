import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Workout/models/advice.model.dart';
import 'package:performance_tracker/core/models/day.model.dart';
import 'package:performance_tracker/core/models/food.model.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';
import 'package:performance_tracker/src/features/Dashboard/models/journey.model.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/core/models/user.model.dart';
import 'package:performance_tracker/src/features/Coach/repositories/conversation.respository.dart';
import 'package:performance_tracker/src/features/Workout/services/advice.service.dart';
import 'package:performance_tracker/core/services/day.service.dart';
import 'package:performance_tracker/core/services/migration.service.dart';
import 'package:performance_tracker/src/features/Nutrition/services/foods.service.dart';
import 'package:performance_tracker/src/features/Journal/services/journal.service.dart';
import 'package:performance_tracker/src/features/Dashboard/services/journey.service.dart';
import 'package:performance_tracker/src/features/Coach/services/report.service.dart';
import 'package:performance_tracker/src/features/Workout/services/routine.service.dart';
import 'package:performance_tracker/src/features/Coach/services/trainer.agent.service.dart';
import 'package:performance_tracker/core/services/user.service.data.dart';
import 'package:performance_tracker/core/services/userGoals.service.dart';
import 'package:performance_tracker/core/models/userGoal.model.dart';
import 'package:performance_tracker/src/features/Workout/services/workout.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';
import 'package:permission_handler/permission_handler.dart';

class DataService {
  final workService = locator<WorkoutService>();
  final foodService = locator<FoodService>();
  final dayService = locator<DayService>();
  final migrationService = locator<MigrationService>();
  final userService = locator<UserService>();
  final goalService = locator<UserGoalsService>();
  final routService = locator<RoutineService>();
  final jourService = locator<JourneyService>();
  final reportService = locator<ReportService>();
  final trainerAgentService = locator<TrainerAgentService>();
  final advService = locator<AdviceService>();
  final journalService = locator<JournalService>();
  final _convoRepo = locator<ConversationRepository>();

  restoreBackUp(oldData) {
    if (oldData['objectStore'] == null) {
      _restoreDataFromBackupMobile(oldData);
      return;
    }
    _restoreDataFromBackupWeb(oldData);
  }

  _restoreDataFromBackupWeb(oldData) async {
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

  _restoreDataFromBackupMobile(oldData) async {
    Fluttertoast.showToast(msg: "Started importing");
    try {
      AppData data = AppData.fromJson(oldData);
      migrationService.migrateImportedData(
          days: data.days,
          journeys: data.journeys,
          routines: data.routines,
          users: data.users,
          goals: data.userGoals);
      List<Future<void>> futures = [
        // Restore Foods
        () async {
          await foodService.clearAllFood();
          for (var food in data.foods) {
            await foodService.addFood(food);
          }
        }(),
        // Restore Days
        () async {
          await dayService.clearAllDays();

          for (var day in data.days) {
            await dayService.addDay(day);
          }
        }(),
        // Restore Users
        () async {
          await userService.clearAllUser();
          for (var user in data.users) {
            await userService.addUser(user);
          }
        }(),
        // Restore User Goals
        () async {
          await goalService.restoreGoals(data.userGoals);
        }(),
        // Restore Routines
        () async {
          await routService.clearAll();
          for (var routine in data.routines) {
            if (routine.dateKey != null) {
              // Auto routine: stored under its DATE_KEY (if it has workouts).
              await routService.updateRoutine(routine);
            } else {
              await routService.addRoutine(routine);
            }
          }
        }(),
        // Restore Workouts
        () async {
          await workService.clearAll();
          for (var workout in data.workouts) {
            await workService.addWorkout(workout);
          }
        }(),
        // Restore Journeys
        () async {
          await jourService.clearAll();
          for (var journey in data.journeys) {
            await jourService.createJourney(journey);
          }
        }(),
        // Restore Advices
        () async {
          await advService.clearAllAdviceSet();
          for (var advice in data.advices) {
            await advService.createAdvice(advice);
          }
        }(),
        // Restore Conversations
        () async {
          await _convoRepo.clearAllChats();
          for (var convo in data.conversations) {
            await _convoRepo.addConversation(convo);
          }
        }(),
        // Restore Reports
        () async {
          await reportService.clearAllReports();
          for (var report in data.reports) {
            await reportService.createReport(report);
          }
        }(),
        // Restore Journals
        () async {
          var book = data.journalBook;
          for(var journal in book?.journals ?? [] )
          {
            await journalService.addJournal(journal,book?.password ?? '');
          }
        }(),
      ];
      await Future.wait(futures);
      Fluttertoast.showToast(msg: "Importing finished");
    } catch (e) {
      Fluttertoast.showToast(msg: "An error has occur ${e.toString()}");
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
    Fluttertoast.showToast(msg: "Preparing to download file");
    try {
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
        version: '',
        journalBook: journalService.getJournalBook(),
        userGoals: goalService.getAllGoals()
      );
      var jsonData = appData.toJson();
      await saveJsonToFile(jsonData, "PerformanceTracker");
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error has occur ${e}');
    }
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
  JournalBook? journalBook;
  List<UserGoal> userGoals;
  String version;
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
    required this.version,
    required this.journalBook,
    required this.userGoals,
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
      "journalBook": journalBook?.toJson(),
      "userGoals": userGoals.map((goal) => goal.toJson()).toList(),
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
      journalBook: map['journalBook']!=null ? JournalBook.fromJson(map['journalBook']) : null,
      // Absent in backups made before goal periods existed.
      userGoals: ((map['userGoals'] as List<dynamic>?) ?? [])
          .map((e) => UserGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      version: map['version'] ??= "",
    );
  }
}

Future<void> saveJsonToFile(Map<String, dynamic> data, String fileName) async {
  // Request storage permission
  var status = await Permission.storage.request();
  if (!status.isGranted) {
    throw( Exception('No access to storage'));
  }

  // Convert Map to JSON string
  String jsonString = jsonEncode(data);
   final directory = await getApplicationDocumentsDirectory();

  String? directoryPath = directory.path;

  if (directoryPath == null) {
    return;
  }

  // Create full path
  String filePath = '${directoryPath}/$fileName.json';
  File file = File(filePath);

  // Write to file
  await file.writeAsString(jsonString);

  Fluttertoast.showToast(msg: "File has been downloaded in $filePath");
}
