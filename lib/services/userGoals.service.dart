import 'dart:async';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';
import 'package:performance_tracker/services/user.service.data.dart';

class UserGoalsService {
  
  var userService = locator<UserService>();
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
      if (steps<= 7000)
      {
        return ActivityLevel.lightlyActive;
      }
      if(steps<= 12000)
      {
        return ActivityLevel.moderatelyActive;
      }
      if(steps<=15000)
      {
        return ActivityLevel.veryActive;
      }
      if(steps > 15000)
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
    if(recommendedUserWeight < user.weight) // SHOULD CUT
    {
      user.userGoals.caloricChangeGoal = CALORIE_DEFICIT_LIMIT;
    }
    if(recommendedUserWeight > user.weight) // SHOULD BULK
    {
      user.userGoals.caloricChangeGoal = CAL_SURPLUS_LIMIT;
    }
    if(recommendedUserWeight > user.weight) // GOOD WEIGHT
    {
      user.userGoals.caloricChangeGoal = 0;
    }
    user.userGoals.caloricChangeGoal = 200;
    await userService.updateUser(user);
    return true;
  }

  setCaloricLimit(User user)
  {
    var maintenanceCalories = fetchMaintenanceCalories(user,steps:user.userGoals.stepGoal);
    if(user.weight > user.userGoals.targetWeight)
    { 
      user.userGoals.calorieLimit = maintenanceCalories- user.userGoals.caloricChangeGoal;
    }
    if(user.weight < user.userGoals.targetWeight)
    {
      user.userGoals.calorieLimit = maintenanceCalories + user.userGoals.caloricChangeGoal;
    }
    if(user.weight == user.userGoals.targetWeight)
    {
      user.userGoals.calorieLimit = maintenanceCalories;
    }
  }
  
  double fetchMaintenanceCalories(User user , {int steps= 3000})
  {
    var bmr = _getBmr(user);
    var activityLevel = getActivity(steps);
    var factor = activityFactor[activityLevel];
    return bmr*factor!;
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
}