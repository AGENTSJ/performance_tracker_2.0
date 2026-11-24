import 'dart:async';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/core/models/food.model.dart';
import 'package:performance_tracker/core/models/user.model.dart';
import 'package:performance_tracker/core/services/user.service.data.dart';

enum JourneyMode { cut, bulk, maintenance }

class UserGoalsService {

  var userService = locator<UserService>();

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

  int getDaysToReachWeightTarget(User user)
  {
    double weightDiff = (user.userGoals.targetWeight - user.weight).abs();
    var caloriesToChange = weightDiff*CALORIES_IN_1KG_FAT;

    var daysToReach = caloriesToChange/user.userGoals.caloricChangeGoal;
    return daysToReach.round();
  }

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

  Future<UserGoals> getUserGoals() async {
    var user = await userService.getUserData();
    return user.userGoals;
  }

  Future<bool> resetGoals() async
  {
    var user = await userService.getUserData();
    user.userGoals.stepGoal = STANDARD_STEP_LIMIT;
    var recommendedUserWeight = getRecommendedWeight(user);
    user.userGoals.targetWeight = recommendedUserWeight.round().toDouble();
    if ((recommendedUserWeight - user.weight).abs() <=
        MAINTENANCE_WEIGHT_TOLERANCE_KG) // GOOD WEIGHT -> MAINTAIN
    {
      user.userGoals.caloricChangeGoal = 0;
    } else if (recommendedUserWeight < user.weight) // SHOULD CUT
    {
      user.userGoals.caloricChangeGoal = CALORIE_DEFICIT_LIMIT;
    } else // SHOULD BULK
    {
      user.userGoals.caloricChangeGoal = CAL_SURPLUS_LIMIT;
    }
    await userService.updateUser(user);
    return true;
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