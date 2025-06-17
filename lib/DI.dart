import 'package:get_it/get_it.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/services/rest.service.dart';

final GetIt locator = GetIt.instance;

setUpDependencyInjection()
{
  locator.registerLazySingleton<FoodService>(()=>FoodService());
  locator.registerLazySingleton<RestService>(()=>RestService());
  locator.registerLazySingleton<AiService>(()=>AiService());
}