import 'package:get_it/get_it.dart';
import 'package:performance_tracker/repository/day.repository.dart';
import 'package:performance_tracker/repository/food.repository.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/comments.service.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/services/rest.service.dart';
import 'package:performance_tracker/services/nutritionInfoProvide.service.dart';

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

  // Repo
  locator.registerLazySingleton<FoodRepository>(()=>FoodRepository());
  locator.registerLazySingleton<DayRepository>(()=>DayRepository());
}