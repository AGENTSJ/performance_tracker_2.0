import 'dart:async';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';
import 'package:performance_tracker/services/user.service.data.dart';

class UserGoalsService {
  final CALORIE_DEFICIT_LIMIT = 500;
  final CAL_SURPLUS_LIMIT = 500;
  final STANDARD_STEP_LIMIT = 5000;
  var userService = locator<UserService>();
  Map<ActivityLevel,double> activityFactor = {
    ActivityLevel.sedentary : 1.2,
    ActivityLevel.lightlyActive : 1.375,
    ActivityLevel.moderatelyActive : 1.55,
    ActivityLevel.veryActive : 1.725,
    ActivityLevel.extraActive : 1.9,
  };

  ActivityLevel getActivity(int steps) {
    switch (steps) {
      case 3000:
        return ActivityLevel.sedentary;
      case 5000:
        return ActivityLevel.lightlyActive;
      case 7000:
        return ActivityLevel.moderatelyActive;
      case 9000:
      case 11000:
        return ActivityLevel.veryActive;
      default:
        return ActivityLevel.sedentary;
    }
  }
  Future<UserGoals> getUserGoals() async {
    var user = await userService.getUserData();

    return user.userGoals;
  }

  Future<bool> resetGoals() async
  {
    var user = await userService.getUserData();
    user.userGoals.stepGoal = STANDARD_STEP_LIMIT;
    user.userGoals.caloricBurn = 200;
    var maintenanceCalories = FetchMaintenanceCalories(user,steps:user.userGoals.stepGoal);
    if(user.weight > user.userGoals.targetWeight)
    { 
      user.userGoals.calorieLimit = maintenanceCalories- CALORIE_DEFICIT_LIMIT;
    }
    if(user.weight < user.userGoals.targetWeight)
    {
      user.userGoals.calorieLimit = maintenanceCalories + CAL_SURPLUS_LIMIT;
    }
    if(user.weight == user.userGoals.targetWeight)
    {
      user.userGoals.calorieLimit = maintenanceCalories;
    }
    await userService.updateUser(user);
    return true;
  }
  double FetchMaintenanceCalories(User user , {int steps= 3000})
  {
    var bmr = _getBmr(user);
    var activityLevel = getActivity(steps);
    var factor = activityFactor[activityLevel];
    return bmr*factor!;
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
}