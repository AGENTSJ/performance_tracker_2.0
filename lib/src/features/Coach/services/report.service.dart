import 'dart:async';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/core/extensions/double_extensions.dart';
import 'package:performance_tracker/core/models/day.model.dart';
import 'package:performance_tracker/core/models/food.model.dart';
import 'package:performance_tracker/core/models/user.model.dart';
import 'package:performance_tracker/src/features/Coach/repositories/report.repository.dart';
import 'package:performance_tracker/src/features/Workout/services/workout.service.dart';
import 'package:performance_tracker/src/features/Workout/services/fatigue.service.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/core/services/ai.service.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/core/services/day.service.dart';
import 'package:performance_tracker/src/features/Dashboard/services/health.service.dart';
import 'package:performance_tracker/src/features/Workout/services/routine.service.dart';
import 'package:performance_tracker/core/services/user.service.data.dart';
import 'package:performance_tracker/core/services/userGoals.service.dart';

class ReportService {
  final ReportRepository _repository = locator<ReportRepository>();
  final _commonService = locator<CommonService>();
  final _userService = locator<UserService>();
  final _dayService = locator<DayService>();
  final _userGoalService = locator<UserGoalsService>();
  final _healthService = locator<HealthService>();
  final _aiService = locator<AiService>();
  final _routineService = locator<RoutineService>();
  final _workoutService = locator<WorkoutService>();
  final _fatigueService = locator<FatigueService>();
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
      var goal = _userGoalService.getActiveGoal();
      var maintenance = _userGoalService.fetchMaintenanceCalories(
        user,
        steps: goal.stepGoal,
        macrosToday,
      );
      var nutritionToday = _dayService.getDaysCalories(today!);
      String context =
          '''User Name : ${user.name}
      Current Weight: ${user.weight}
      Height: ${user.height}
      User target weight : ${goal.targetWeight}
      User target steps per day: ${goal.stepGoal}
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
    buffer.writeln("Performance Analysis For Each Set");
    buffer.write(_buildProgressionTable(workout, enabledSets,));
    if (workout.desc.trim().isNotEmpty) {
      buffer.writeln(
        "**User journal while doing the workout:** ${workout.desc}",
      );
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
    routineSummary +=
        '''\nFatigue Adjusted Reps estimates how many reps you could have performed on a set if it had been performed fresh, without any fatigue accumulated from previous exercises and sets in the workout.
    The system analyzes the fatigue generated by all work performed before that set and adjusts the observed performance accordingly. This helps normalize results when:

    Exercises are performed in a different order
    Sets are skipped or added
    Extra volume is performed earlier in the session
    Fatigue levels vary between workouts

    The goal is to provide a more consistent measure of underlying strength and performance by reducing the impact of workout-specific fatigue.\n''';
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
    routineSummary += "\nUser Journal of routine if any ${routine.desc}";
    if (previousReport == null ||
        (routineEntityLastUpdatedAt != null &&
            previousReport.entityLastUpdated.isBefore(
              routineEntityLastUpdatedAt,
            ))) {
      print("started ${routine.name} context");
      final modelName = await _aiService.getSelectedModel();
      var resp = await _aiService.getResponse(
        routineSummary,
        "Summaries this routine and draw out important observation",
        modelType: Models.Pro,
        modelName: modelName,
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

  Future<List<Report>>  getAndCreateAllWorkoutReports() async {
    List<Report> reports = []; 
    var workouts = await _workoutService.getAllWorkouts();
    for (var workout in workouts) {
      var rep = await getWorkoutReport(workout, null);
      reports.add(rep);
    }
    return reports;
  }
  /// Concatenates every stored report of [type] into a single markdown string
  /// ready to be dropped on the clipboard. Returns an empty string when no
  /// report of that type is stored.
  String buildReportsExport(EntityType type) {
    final typeReports = fetchAllReports()
        .where((report) => report.type == type)
        .toList()
      ..sort((a, b) => a.generatedAt.compareTo(b.generatedAt));
    if (typeReports.isEmpty) {
      return "";
    }

    final now = DateTime.now();
    final title = "${type.name[0].toUpperCase()}${type.name.substring(1)}";
    final buffer = StringBuffer();
    buffer.writeln("# $title reports (${typeReports.length})");
    buffer.writeln(
      "Exported on ${_commonService.getDateString(now)} ${_commonService.getTimeString(now)}",
    );
    buffer.writeln();

    for (var report in typeReports) {
      buffer.writeln("---");
      buffer.writeln();
      buffer.writeln("### ${report.entityName}");
      buffer.writeln(
        "Generated: ${_commonService.getDateString(report.generatedAt)} ${_commonService.getTimeString(report.generatedAt)}",
      );
      buffer.writeln(
        "Last updated: ${_commonService.getDateString(report.entityLastUpdated)} ${_commonService.getTimeString(report.entityLastUpdated)}",
      );
      buffer.writeln();
      buffer.writeln(report.reportData.trim());
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Builds a markdown export of the last [weeks] week(s) of nutrition: a daily
  /// rollup table followed by the meal by meal breakdown of each day.
  Future<String> buildNutritionExport(int weeks) async {
    final from = _windowStart(weeks);
    final days = _daysInLastWeeks(weeks);
    final user = await _userService.getUserData();

    final buffer = StringBuffer();
    buffer.writeln("# Nutrition export - last ${weeks * 7} days");
    buffer.write(_buildExportHeader(user, from));

    if (days.isEmpty) {
      buffer.writeln("_No days logged in this period._");
      return buffer.toString();
    }

    // Gather the numbers once so the rollup table and the daily breakdown
    // below it always agree with each other.
    final macrosByDay = <Day, MacroNutrients>{};
    final stepsByDay = <Day, int>{};
    final maintenanceByDay = <Day, double>{};
    for (var day in days) {
      final macros = _dayService.getDaysCalories(day);
      final steps = await _stepsForDay(day);
      macrosByDay[day] = macros;
      stepsByDay[day] = steps;
      maintenanceByDay[day] = _userGoalService.fetchMaintenanceCalories(
        user,
        macros,
        steps: steps,
      );
    }

    buffer.writeln("## Daily totals");
    buffer.writeln();
    buffer.writeln(
      "| Date | Calories | Protein (g) | Carbs (g) | Fat (g) | Fiber (g) | Steps | Maintenance | Calorie goal |",
    );
    buffer.writeln("| --- | --- | --- | --- | --- | --- | --- | --- | --- |");
    for (var day in days) {
      final macros = macrosByDay[day]!;
      buffer.writeln(
        "| ${_commonService.getDateString(day.dayTime)} "
        "| ${_fmtNutrient(macros.calories)} "
        "| ${_fmtNutrient(macros.protein)} "
        "| ${_fmtNutrient(macros.carbohydrate)} "
        "| ${_fmtNutrient(macros.fat)} "
        "| ${_fmtNutrient(macros.fiber)} "
        "| ${stepsByDay[day]} "
        "| ${_fmtNutrient(maintenanceByDay[day])} "
        "| ${_fmtNutrient(_calorieGoalForDay(user, day, maintenanceByDay[day]!))} |",
      );
    }
    buffer.writeln();

    buffer.writeln("Days logged in this period: ${days.length}");
    buffer.writeln(
      "Daily averages: "
      "${_fmtNutrient(_average(macrosByDay.values.map((m) => m.calories)))} kcal, "
      "protein ${_fmtNutrient(_average(macrosByDay.values.map((m) => m.protein)))}g, "
      "carbs ${_fmtNutrient(_average(macrosByDay.values.map((m) => m.carbohydrate)))}g, "
      "fat ${_fmtNutrient(_average(macrosByDay.values.map((m) => m.fat)))}g, "
      "fiber ${_fmtNutrient(_average(macrosByDay.values.map((m) => m.fiber)))}g, "
      "steps ${_average(stepsByDay.values.map((s) => s.toDouble())).round()}",
    );
    buffer.writeln();

    buffer.writeln("## Daily breakdown");
    buffer.writeln();
    for (var day in days) {
      final macros = macrosByDay[day]!;
      buffer.writeln("### ${_commonService.getDateString(day.dayTime)}");
      buffer.writeln(
        "Calories ${_fmtNutrient(macros.calories)} | "
        "Protein ${_fmtNutrient(macros.protein)}g | "
        "Carbs ${_fmtNutrient(macros.carbohydrate)}g | "
        "Fat ${_fmtNutrient(macros.fat)}g | "
        "Fiber ${_fmtNutrient(macros.fiber)}g",
      );
      buffer.writeln(
        "Steps ${stepsByDay[day]} | "
        "Maintenance calories ${_fmtNutrient(maintenanceByDay[day])}",
      );
      buffer.writeln();

      final meals = (day.meals ?? [])
          .where((meal) => meal.foods.isNotEmpty)
          .toList();
      if (meals.isEmpty) {
        buffer.writeln("_No food logged._");
        buffer.writeln();
        continue;
      }
      for (var meal in meals) {
        buffer.writeln("**${meal.mealName}**");
        for (var food in meal.foods) {
          buffer.writeln(
            "- ${food.name} "
            "${_fmtNutrient(food.quantity.value)}${food.quantity.unit} - "
            "${_fmtNutrient(food.macros.calories)} kcal "
            "(P ${_fmtNutrient(food.macros.protein)}g, "
            "C ${_fmtNutrient(food.macros.carbohydrate)}g, "
            "F ${_fmtNutrient(food.macros.fat)}g, "
            "Fiber ${_fmtNutrient(food.macros.fiber)}g)",
          );
        }
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  /// Builds a markdown export of the last [weeks] week(s) of movement: steps
  /// walked per day against the step goal that was in place on that day.
  Future<String> buildActivityExport(int weeks) async {
    final from = _windowStart(weeks);
    final days = _daysInLastWeeks(weeks);
    final user = await _userService.getUserData();

    final buffer = StringBuffer();
    buffer.writeln("# Activity export - last ${weeks * 7} days");
    buffer.write(_buildExportHeader(user, from));

    if (days.isEmpty) {
      buffer.writeln("_No days logged in this period._");
      return buffer.toString();
    }

    final stepsByDay = <Day, int>{};
    for (var day in days) {
      stepsByDay[day] = await _stepsForDay(day);
    }

    buffer.writeln("## Daily steps");
    buffer.writeln();
    buffer.writeln("| Date | Steps | Step goal | Goal met | Move minutes |");
    buffer.writeln("| --- | --- | --- | --- | --- |");
    var daysGoalMet = 0;
    for (var day in days) {
      final steps = stepsByDay[day]!;
      // Each day is measured against the goal period it falls in, falling
      // back to the active goal for days before the first period.
      final goal = (_userGoalService.getGoalForDate(day.dayTime) ??
              _userGoalService.getActiveGoal())
          .stepGoal;
      final goalMet = goal > 0 && steps >= goal;
      if (goalMet) {
        daysGoalMet++;
      }
      buffer.writeln(
        "| ${_commonService.getDateString(day.dayTime)} "
        "| $steps "
        "| $goal "
        "| ${goalMet ? 'yes' : 'no'} "
        "| ${_healthService.getMoveMin(steps).inMinutes} |",
      );
    }
    buffer.writeln();

    final totalSteps = stepsByDay.values.fold<int>(0, (sum, s) => sum + s);
    buffer.writeln("Days logged in this period: ${days.length}");
    buffer.writeln("Total steps: $totalSteps");
    buffer.writeln(
      "Average steps per day: "
      "${_average(stepsByDay.values.map((s) => s.toDouble())).round()}",
    );
    buffer.writeln("Days the step goal was met: $daysGoalMet");
    return buffer.toString();
  }

  /// Calorie target for [day] from the goal period it falls in.
  double? _calorieGoalForDay(User user, Day day, double maintenance) {
    final goal = _userGoalService.getGoalForDate(day.dayTime);
    if (goal == null) return null;
    return _userGoalService.getCalorieTarget(user, goal, maintenance);
  }

  /// The user block every export opens with, plus the window it covers.
  String _buildExportHeader(User user, DateTime from) {
    final buffer = StringBuffer();
    buffer.writeln(
      "${_commonService.getDateString(from)} to ${_commonService.getDateString(DateTime.now())}",
    );
    buffer.writeln();
    buffer.writeln("User Name : ${user.name}");
    buffer.writeln("Current Weight: ${user.weight}");
    buffer.writeln("Height: ${user.height}");
    final goal = _userGoalService.getActiveGoal();
    buffer.writeln("User target weight : ${goal.targetWeight}");
    buffer.writeln("User target steps per day: ${goal.stepGoal}");
    buffer.writeln();
    return buffer.toString();
  }

  /// First day of the window covering the last [weeks] week(s), today included.
  DateTime _windowStart(int weeks) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: weeks * 7 - 1));
  }

  /// Days already stored inside the last [weeks] week(s), oldest first. Reads
  /// storage straight so no empty day is created for a date never opened.
  List<Day> _daysInLastWeeks(int weeks) {
    final now = DateTime.now();
    final from = _windowStart(weeks);
    final until = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return _dayService
        .getAllDays()
        .where(
          (day) => !day.dayTime.isBefore(from) && !day.dayTime.isAfter(until),
        )
        .toList()
      ..sort((a, b) => a.dayTime.compareTo(b.dayTime));
  }

  /// Steps for [day] from the health platform, falling back to what the day
  /// stored when the platform has no permission to answer.
  Future<int> _stepsForDay(Day day) async {
    final steps = await _healthService.getStepsByDate(day.dayTime);
    return steps == 0 ? (day.activity?.steps ?? 0) : steps;
  }

  String _fmtNutrient(double? value) => value.safe.toStringAsFixed(1);

  double _average(Iterable<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    return values.fold<double>(0, (sum, value) => sum + value.safe) /
        values.length;
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
    final fatigue = _fatigueService.calculator();
    String cellFor(WorkSet set, String label) {
      for (var entry in set.history) {
        if (!withinRange(entry)) continue;
        if (_commonService.getDateString(entry.entryDate) == label) {
          return workout
              .getFatigueAdjustedReps(
                fatigue.contextFor(entry, workout),
                entry.value,
              )
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

  String _buildProgressionTable(Workout workout, List<WorkSet> enabledSets) {
    final buffer = StringBuffer();

    buffer.writeln("| Weight | Trend |");
    buffer.writeln("| --- | --- |");

    for (final set in enabledSets) {
      final progression = _workoutService.getWorkSetProgression(
        workout,
        set.history,
      );

      buffer.writeln("| ${set.value}kg | ${progression.name} |");
    }
    buffer.writeln();
    return buffer.toString();
  }
}
