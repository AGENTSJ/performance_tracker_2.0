import 'dart:async';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/core/models/food.model.dart';
import 'package:performance_tracker/core/models/user.model.dart';
import 'package:performance_tracker/core/models/userGoal.model.dart';
import 'package:performance_tracker/core/repositories/userGoal.repository.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/core/services/user.service.data.dart';

enum JourneyMode { cut, bulk, maintenance }

class UserGoalsService {

  var userService = locator<UserService>();
  final _goalRepo = locator<UserGoalRepository>();
  final _commonService = locator<CommonService>();

  /// Classifies a user's current goal as a cut, bulk or maintenance.
  /// Maintenance applies when the target weight is essentially the current
  /// weight, or when there is no caloric change goal set.
  JourneyMode getJourneyMode(User user) {
    final goals = user.userGoals;
    final weightDiff = (goals.targetWeight - user.weight).abs();
    if (weightDiff <= MAINTENANCE_WEIGHT_TOLERANCE_KG ||
        goals.caloricChangeGoal == 0) {
      return JourneyMode.maintenance;
    }
    return goals.targetWeight < user.weight
        ? JourneyMode.cut
        : JourneyMode.bulk;
  }

  /// Signed deviation of [calories] from [maintenance] as a percentage.
  /// Negative means under maintenance, positive means over.
  double getMaintenanceDeviationPercent(double calories, double maintenance) {
    if (maintenance == 0) return 0;
    return ((calories - maintenance) / maintenance) * 100;
  }

  /// Whether [calories] is close enough to [maintenance] to count as a day
  /// "on track" while maintaining.
  bool isWithinMaintenance(double calories, double maintenance) {
    return getMaintenanceDeviationPercent(calories, maintenance).abs() <=
        MAINTENANCE_ADHERENCE_TOLERANCE_PERCENT;
  }
  Map<ActivityLevel,double> activityFactor = {
    ActivityLevel.sedentary : 1.2,
    ActivityLevel.lightlyActive : 1.375,
    ActivityLevel.moderatelyActive : 1.55,
    ActivityLevel.veryActive : 1.725,
    ActivityLevel.extraActive : 1.9,
  };

  int getDaysToReachWeightTarget(User user, UserGoal goal)
  {
    double weightDiff = (goal.targetWeight - user.weight).abs();
    var caloriesToChange = weightDiff*CALORIES_IN_1KG_FAT;

    var daysToReach = caloriesToChange/goal.caloricChangeGoal;
    return daysToReach.round();
  }

  /// Daily calorie target: maintenance minus the caloric change goal when
  /// losing weight, plus it when gaining.
  double getCalorieTarget(User user, UserGoal goal, double maintenance)
  {
    return user.weight >= goal.targetWeight
        ? maintenance - goal.caloricChangeGoal
        : maintenance + goal.caloricChangeGoal;
  }

  // ---------------------------------------------------------------------------
  // Goal periods
  // ---------------------------------------------------------------------------

  /// The active goal. On first launch, when none exists yet, a default one
  /// starting today is created.
  UserGoal getActiveGoal() {
    final active = _goalRepo.getActiveGoal();
    if (active != null) return active;
    final goal = UserGoal(
      startDate: _dateOnly(DateTime.now()),
      isActive: true,
      stepGoal: 5000,
      targetWeight: 71,
      caloricChangeGoal: 200,
    );
    // Hive applies the add in memory right away; the disk write finishes after.
    _goalRepo.addGoal(goal);
    return goal;
  }

  /// The goal whose period covers [date], if any.
  UserGoal? getGoalForDate(DateTime date) {
    final dateKey = _commonService.getDateKey(date);
    for (final goal in _goalRepo.getAllGoals()) {
      final start = _commonService.getDateKey(goal.startDate);
      final end = goal.endDate == null
          ? null
          : _commonService.getDateKey(goal.endDate!);
      if (start.compareTo(dateKey) <= 0 &&
          (end == null || dateKey.compareTo(end) <= 0)) {
        return goal;
      }
    }
    return null;
  }

  UserGoal? getGoalById(int id) => _goalRepo.getGoalById(id);

  List<UserGoal> getAllGoals() => _goalRepo.getAllGoals();

  /// Replaces all goals with [goals] (backup restore).
  Future<void> restoreGoals(List<UserGoal> goals) async {
    await _goalRepo.clearAllGoals();
    for (final goal in goals) {
      await _goalRepo.addGoal(goal);
    }
  }

  /// Saves new goal values. If the active goal started today it is edited in
  /// place; otherwise it is ended yesterday and a new active goal starts
  /// today, so periods never overlap and only one goal is active.
  Future<UserGoal> saveGoal({
    required int stepGoal,
    required double targetWeight,
    required double caloricChangeGoal,
  }) async {
    final today = _dateOnly(DateTime.now());
    var goal = getActiveGoal();
    if (_commonService.getDateKey(goal.startDate) ==
        _commonService.getDateKey(today)) {
      goal
        ..stepGoal = stepGoal
        ..targetWeight = targetWeight
        ..caloricChangeGoal = caloricChangeGoal;
      await _goalRepo.updateGoal(goal);
    } else {
      goal
        ..isActive = false
        ..endDate = today.subtract(const Duration(days: 1));
      await _goalRepo.updateGoal(goal);
      goal = UserGoal(
        startDate: today,
        isActive: true,
        stepGoal: stepGoal,
        targetWeight: targetWeight,
        caloricChangeGoal: caloricChangeGoal,
      );
      await _goalRepo.addGoal(goal);
    }
    await _mirrorToUser(goal);
    return goal;
  }

  /// Temporary until Phase 4: journeys still read goals from their copy of
  /// the user (`userAtStart.userGoals`, `userAtDay.userGoals`), so the user
  /// record keeps a copy of the active goal's values.
  Future<void> _mirrorToUser(UserGoal goal) async {
    final user = await userService.getUserData();
    user.userGoals
      ..stepGoal = goal.stepGoal
      ..targetWeight = goal.targetWeight
      ..caloricChangeGoal = goal.caloricChangeGoal;
    await userService.updateUser(user);
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  ActivityLevel getActivity(int steps) {
      if (steps<= 3500)
      {
        return ActivityLevel.sedentary;
      }
      if (steps<= 10000)
      {
        return ActivityLevel.lightlyActive;
      }
      if(steps<= 14000)
      {
        return ActivityLevel.moderatelyActive;
      }
      if(steps<=20000)
      {
        return ActivityLevel.veryActive;
      }
      if(steps > 20000)
      {
        return ActivityLevel.extraActive;
      }
      return ActivityLevel.sedentary;
  }

  /// Saves the recommended goals as the active goal.
  Future<UserGoal> resetGoals() async
  {
    var user = await userService.getUserData();
    var recommendedUserWeight = getRecommendedWeight(user);
    double caloricChangeGoal;
    if ((recommendedUserWeight - user.weight).abs() <=
        MAINTENANCE_WEIGHT_TOLERANCE_KG) // GOOD WEIGHT -> MAINTAIN
    {
      caloricChangeGoal = 0;
    } else if (recommendedUserWeight < user.weight) // SHOULD CUT
    {
      caloricChangeGoal = CALORIE_DEFICIT_LIMIT;
    } else // SHOULD BULK
    {
      caloricChangeGoal = CAL_SURPLUS_LIMIT;
    }
    return saveGoal(
      stepGoal: STANDARD_STEP_LIMIT,
      targetWeight: recommendedUserWeight.round().toDouble(),
      caloricChangeGoal: caloricChangeGoal,
    );
  }
  
  double fetchMaintenanceCalories(User user , MacroNutrients macro,{int steps= 3500})
  {
    var bmr = _getBmr(user);
    var calories = 0.0;
    var neat = 150;
    var tde = _getThermicEffectOfFood(macro);
    const MET = 3;
    if(steps<3500)
    {
      steps = 3500;
    }
    var moveMin = _getMoveMin(steps);
    calories = bmr+neat+tde+(moveMin.inMinutes*MET);
    return calories;
  }

  double _getThermicEffectOfFood(MacroNutrients macro)
  {
    var calBurnInProteins = macro.protein*1.2;
    var calBurnInCarb = macro.protein*0.4;
    var calBurnInFat = macro.protein*0.27;
    return calBurnInFat+calBurnInCarb+calBurnInProteins;
  }
  double getBMI(User user)
  {
    
    double heightInMeters = user.height / 100;
    return user.weight / (heightInMeters * heightInMeters);
  }

  double getRecommendedWeight(User user)
  {
    var hInMeter = (user.height)/100; 
    return hInMeter*hInMeter*RECOMMENDED_B_M_I;
  }

  double _getBmr(User user)
  {
    switch (user.gender)
    {
      case Gender.male:
        return (10*user.weight)+(6.25*user.height) - (5 * user.age)+5;
      case Gender.female:
        return (10*user.weight)+(6.25*user.height) - (5 * user.age) -161;
      default:
        return (10*user.weight)+(6.25*user.height) - (5 * user.age) -161;
    }
  }
  Duration _getMoveMin(int steps) {
    const secondToTakeAStep = 0.5;
    var totalSeconds = (steps * secondToTakeAStep).round();
    return Duration(seconds: totalSeconds);
  }
}