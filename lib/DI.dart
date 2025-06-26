import 'package:get_it/get_it.dart';
import 'package:performance_tracker/modules/nutritionModule/repository/day.repository.dart';
import 'package:performance_tracker/modules/nutritionModule/repository/food.repository.dart';
import 'package:performance_tracker/modules/sharedModule/services/ai.service.dart';
import 'package:performance_tracker/modules/sharedModule/services/avatar.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/comments.service.dart';
import 'package:performance_tracker/modules/sharedModule/services/common.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/day.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/foods.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/rest.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/nutritionInfoProvide.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/userGoals.service.dart';

final GetIt locator = GetIt.instance;

setUpDependencyInjection()
{
  locator.registerLazySingleton<FoodService>(()=>FoodService());
  locator.registerLazySingleton<RestService>(()=>RestService());
  locator.registerLazySingleton<AiService>(()=>AiService());
  locator.registerLazySingleton<DayService>(()=>DayService());
  locator.registerLazySingleton<CommonService>(()=>CommonService());
  locator.registerLazySingleton<NutritionServiceProvider>(()=>NutritionServiceProvider());
  locator.registerLazySingleton<CommentsService>(()=>CommentsService());
  locator.registerLazySingleton<AvatarService>(()=>AvatarService());
  locator.registerLazySingleton<UserGoalsService>(()=>UserGoalsService());

  // Repo
  locator.registerLazySingleton<FoodRepository>(()=>FoodRepository());
  locator.registerLazySingleton<DayRepository>(()=>DayRepository());
}