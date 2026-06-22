import 'dart:async';
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

  Future<void> clearAllReports() async {
    await _repository.removeAllReports();
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
      var macrosToday = _dayService.getDaysCalories(today!);
      var maintenance = _userGoalService.fetchMaintenanceCalories(
        user,
        steps: user.userGoals.stepGoal,
        macrosToday
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
        type: EntityType.nutrition,
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
    var enabledSets = workout.sets.where((set) => set.enabled).toList();
    var totalEnabledSet = enabledSets.length;

    final buffer = StringBuffer();
    buffer.writeln("## ${workout.name}");
    buffer.writeln();
    buffer.writeln("Total volume across $totalEnabledSet enabled set(s):");
    buffer.writeln();

    for (var vol in workout.volumes) {
      buffer.writeln("- ${vol.muscleName}: ${vol.volume * totalEnabledSet}");
    }
    buffer.writeln();

    buffer.write(_buildSetMatrix(workout, enabledSets, summaryFromDate));
    if (workout.desc.trim().isNotEmpty) {
      buffer.writeln("**User journal while doing the workout:** ${workout.desc}");
    }
    var workRep = buffer.toString();

    var previousReport = fetchReportsByEntityId(entityId);

    Report? report;
    final now = DateTime.now();
    report = Report(
      generatedAt: now,
      entityLastUpdated: now,
      entityId: entityId,
      reportData: workRep,
      entityName: workout.name,
      type: EntityType.workout,
    );
    if (previousReport != null) {
      await removeReport(previousReport.key);
    }
    await createReport(report);
    return report;
  }

  Future<Report> getRoutineReport(
    Routine routine,
    DateTime? summaryFromDate,
  ) async {
    var entityId = "Routine ${routine.key}";
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
      // break;
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
    routineSummary+="\nUser Journal of routine if any ${routine.desc}";
    if (previousReport == null ||
        (routineEntityLastUpdatedAt != null &&
        previousReport.entityLastUpdated.isBefore(routineEntityLastUpdatedAt))) {
      print("started ${routine.name} context");

      var resp = await _aiService.getResponse(
        routineSummary,
        "Summaries this routine and draw out important observation",
        modelType: Models.Pro,
      );
      print("finished ${routine.name} context");

      routineEntityLastUpdatedAt ??= DateTime.now();
      report = Report(
        generatedAt: DateTime.now(),
        entityLastUpdated: routineEntityLastUpdatedAt,
        entityId: entityId,
        reportData: resp.message,
        entityName: routine.name,
        type: EntityType.routine,
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

  /// Builds a single markdown matrix of the workout's performance:
  /// columns are the dates the user trained, rows are each enabled set's
  /// weight, and each cell is the fatigue-adjusted reps for that weight on
  /// that date (blank when the set wasn't logged that day).
  String _buildSetMatrix(
    Workout workout,
    List<WorkSet> enabledSets,
    DateTime? summaryFromDate,
  ) {
    bool withinRange(TrackEntry entry) =>
        summaryFromDate == null || !entry.entryDate.isBefore(summaryFromDate);

    // Collect the unique training days across all enabled sets, ordered.
    final Map<String, DateTime> dateByLabel = {};
    for (var set in enabledSets) {
      for (var entry in set.history) {
        if (!withinRange(entry)) continue;
        dateByLabel.putIfAbsent(
          _commonService.getDateString(entry.entryDate),
          () => entry.entryDate,
        );
      }
    }
    final dateLabels = dateByLabel.keys.toList()
      ..sort((a, b) => dateByLabel[a]!.compareTo(dateByLabel[b]!));

    final buffer = StringBuffer();
    if (dateLabels.isEmpty) {
      buffer.writeln("_No entries logged._");
      buffer.writeln();
      return buffer.toString();
    }

    // Fatigue-adjusted reps for a set on a given day, or "" if not logged.
    String cellFor(WorkSet set, String label) {
      for (var entry in set.history) {
        if (!withinRange(entry)) continue;
        if (_commonService.getDateString(entry.entryDate) == label) {
          return workout
              .getFatigueAdjustedReps(entry.fatigueContext, entry.value)
              .toStringAsFixed(2);
        }
      }
      return "";
    }

    buffer.writeln("Fatigue-adjusted reps (rows = weight, columns = date):");
    buffer.writeln();
    buffer.writeln("| Weight | ${dateLabels.join(' | ')} |");
    buffer.writeln("| --- |${dateLabels.map((_) => ' --- |').join()}");
    for (var set in enabledSets) {
      final cells = dateLabels.map((label) => cellFor(set, label)).join(' | ');
      buffer.writeln("| ${set.value}kg | $cells |");
    }
    buffer.writeln();

    return buffer.toString();
  }
}

