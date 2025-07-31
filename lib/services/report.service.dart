import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/repositories/report.repository.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/health.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/services/userGoals.service.dart';

class ReportService {
  final ReportRepository _repository = locator<ReportRepository>();
  final _commonService = locator<CommonService>();
  final _userService = locator<UserService>();
  final _dayService = locator<DayService>();
  final _userGoalService = locator<UserGoalsService>();
  final _healthService = locator<HealthService>();
  final _aiService = locator<AiService>();
  final _routineService = locator<RoutineService>();
  ReportService();

  Future<void> createReport(Report report) async {
    await _repository.addReport(report);
  }

  List<Report> fetchAllReports() {
    return _repository.getAllReports();
  }

  Report? fetchReportByKey(dynamic key) {
    return _repository.getReportByKey(key);
  }

  Report? fetchReportsByEntityId(String entityId) {
    return _repository.getReportsByEntityId(entityId);
  }

  Future<void> updateReport(dynamic key, Report report) async {
    await _repository.updateReport(key, report);
  }

  Future<void> removeReport(dynamic key) async {
    await _repository.deleteReport(key);
  }

  Future<Report> getNutritionReport() async {
    var now = DateTime.now();
    var entityId = "Nutrition";
    var previousReport = fetchReportsByEntityId(entityId);
    Report? report;
    if (previousReport == null ||
        now.difference(previousReport.entityLastUpdated).inHours > 1) {
      var user = await _userService.getUserData();
      var today = await _dayService.getDayDataByDate(now);
      var stepsToday = await _healthService.getStepsByDate(now);
      var maintenance = _userGoalService.fetchMaintenanceCalories(
        user,
        steps: user.userGoals.stepGoal,
      );
      var nutritionToday = _dayService.getDaysCalories(today!);
      String context =
          '''User Name : ${user.name}
      Current Weight: ${user.weight}
      Height: ${user.height}
      User target weight : ${user.userGoals.targetWeight}
      User target steps per day: ${user.userGoals.stepGoal}
      User Steps today:$stepsToday
      Today's Nutrition:
        Protein: ${nutritionToday.protein}g
        Fat: ${nutritionToday.fat}g
        Carbohydrate: ${nutritionToday.carbohydrate}g
        Fiber: ${nutritionToday.fiber}g
        Calories: ${nutritionToday.calories}
      Maintenance Calories: $maintenance
    ''';
      report = Report(
        generatedAt: now,
        entityLastUpdated: now,
        entityId: entityId,
        reportData: context,
        entityName: 'Nutrition on ${_commonService.getDateString(now)}',
        type: EntityType.nutrition
      );
      if (previousReport != null) {
        await removeReport(previousReport);
      }
      createReport(report);
    } else {
      report = previousReport;
    }

    return report;
  }

  Future<Report> getWorkoutReport(
    Workout workout,
    DateTime? summaryFromDate,
  ) async {
    var entityId = "Workout ${workout.key}";
    var enabledSets = workout.sets.where((set) => set.enabled);
    var totalEnabledSet = enabledSets.length;
    String workRep =
        '''Workout name : ${workout.name}\nFrom Total of $totalEnabledSet sets User gets an total volume of :\n''';
    // getting volume information
    for (var vol in workout.volumes) {
      workRep += "\t${vol.muscleName} ${vol.volume * totalEnabledSet}\n";
    }
    workRep += "Sets descriptions :\n";
    var i = 1;
    DateTime? workRecentlyUpdatedTime;
    for (var set in enabledSets) {
      var summary = _summarizeSetPerformance(set, summaryFromDate, i);
      var setSummary = summary.data;
      var setLastUpdated = summary.recentUpdate;
      workRecentlyUpdatedTime ??= setLastUpdated;
      if (setLastUpdated != null &&
          workRecentlyUpdatedTime!.isBefore(setLastUpdated)) {
        // an entry is added on an set
        workRecentlyUpdatedTime = setLastUpdated;
      }
      workRep += setSummary;
      i++;
    }
    var previousReport = fetchReportsByEntityId(entityId);
    Report? report;
    if (previousReport == null ||
        workRecentlyUpdatedTime == null ||
        previousReport.entityLastUpdated.isBefore(workRecentlyUpdatedTime)) {
      // outdated preivous report or no previous report
      var resp = await _aiService.getResponse(
        workRep,
        '''You are a agent who is assigned with the crucial task of analyzing an workout and its performance and draw out an observation you must closely observe the data and provide insights that describes user performance in the workout this could guide agents in the chain further up to analyze and provide valuable advices to user ,  Respond with maximally dense, information-rich sentences. Eliminate all decorative language. Every sentence must convey essential detail, without omissions or filler.
        ''',
      );
      report = Report(
        generatedAt: DateTime.now(),
        entityLastUpdated: workRecentlyUpdatedTime!,
        entityId: entityId,
        reportData: resp.message,
        entityName: workout.name,
        type: EntityType.workout
      );
      if (previousReport != null) {
        // removing old report
        await removeReport(previousReport.key);
      }
      await createReport(report);
    } else {
      report = previousReport;
    }
    return report;
  }

  Future<Report> getRoutineReport(
    Routine routine,
    DateTime? summaryFromDate,
  ) async {
    var entityId = "Routine ${routine.key}";
    print(routine.name);
    var routineSummary =
        "Routine name : ${routine.name}\nVolumes in the Routine : \n";
    var workouts = await _routineService.getRoutinesWorkouts(routine);
    var volumes = await _routineService.getRoutinesVolume(routine);
    List<Future<Report>> futures = [];
    var previousReport = fetchReportsByEntityId(entityId);
    Report? report;
    DateTime? routineEntityLastUpdatedAt;

    for (var vol in volumes) {
      routineSummary += "\t${vol.muscleName} ${vol.volume}\n";
    }
    for (var work in workouts) {
      futures.add(getWorkoutReport(work, summaryFromDate));
    }
    final results = await Future.wait(futures);
    for (var res in results) {
      routineSummary += "${res.reportData}\n\n";
      routineEntityLastUpdatedAt ??= res.entityLastUpdated;
      if (routineEntityLastUpdatedAt.isBefore(res.entityLastUpdated)) {
        // new entry has been added in some workout
        routineEntityLastUpdatedAt = res.entityLastUpdated;
      }
    }
    if (previousReport == null ||
        routineEntityLastUpdatedAt == null ||
        previousReport.entityLastUpdated.isBefore(routineEntityLastUpdatedAt)) {
      var resp = await _aiService.getResponse(
        routineSummary,
        "Summaries this routine and draw out important observation",
        modelType: Models.Pro,
      );
      report = Report(
        generatedAt: DateTime.now(),
        entityLastUpdated: routineEntityLastUpdatedAt!,
        entityId: entityId,
        reportData: resp.message,
        entityName: routine.name,
        type: EntityType.routine
      );
      if (previousReport != null) {
        await removeReport(previousReport.key);
      }
      await createReport(report);
    } else {
      report = previousReport;
    }
    return report;
  }

  SummaryDTO<String> _summarizeSetPerformance(
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

    return SummaryDTO(
      recentUpdate: contextEntries.isEmpty
          ? null
          : contextEntries.last.entryDate,
      data: setSummary,
    );
  }
}
