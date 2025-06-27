import 'package:get_it/get_it.dart';
import 'package:performance_tracker/repositories/day.repository.dart';
import 'package:performance_tracker/modules/nutritionModule/repository/food.repository.dart';
import 'package:performance_tracker/repositories/user.repository.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/comments.service.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/day.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/foods.service.dart';
import 'package:performance_tracker/services/rest.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/nutritionInfoProvide.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';

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
  locator.registerLazySingleton<UserService>(()=>UserService());

  // Repo
  locator.registerLazySingleton<FoodRepository>(()=>FoodRepository());
  locator.registerLazySingleton<DayRepository>(()=>DayRepository());
  locator.registerLazySingleton<UserRepository>(()=>UserRepository());
}