import 'package:get_it/get_it.dart';
import 'package:performance_tracker/repositories/advice.repository.dart';
import 'package:performance_tracker/repositories/conversation.respository.dart';
import 'package:performance_tracker/repositories/dataAdaptation.service.dart';
import 'package:performance_tracker/repositories/day.repository.dart';
import 'package:performance_tracker/repositories/food.repository.dart';
import 'package:performance_tracker/repositories/journey.repository.dart';
import 'package:performance_tracker/repositories/report.repository.dart';
import 'package:performance_tracker/repositories/routine.repository.dart';
import 'package:performance_tracker/repositories/user.repository.dart';
import 'package:performance_tracker/services/advice.service.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/comments.service.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/services/health.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/maintainance.service.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/services/rest.service.dart';
import 'package:performance_tracker/services/nutritionInfoProvide.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/src/features/Coach/usecases/coach_client_mcp.dart';
import 'package:performance_tracker/src/features/Coach/usecases/coach_server.mcp.dart';

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
  locator.registerLazySingleton<WorkoutService>(()=>WorkoutService());
  locator.registerLazySingleton<RoutineService>(()=>RoutineService());
  locator.registerLazySingleton<MaintainanceService>(()=>MaintainanceService());
  locator.registerLazySingleton<DataService>(()=>DataService());
  locator.registerLazySingleton<HealthService>(()=>HealthService());
  locator.registerLazySingleton<TrainerAgentService>(()=>TrainerAgentService());
  locator.registerLazySingleton<JourneyService>(()=>JourneyService());
  locator.registerLazySingleton<AdviceService>(()=>AdviceService());
  locator.registerLazySingleton<ReportService>(()=>ReportService());
  locator.registerLazySingleton<CoachClientMcp>(()=>CoachClientMcp());
  locator.registerLazySingleton<CoachServerMcp>(()=>CoachServerMcp());

  // Repo
  locator.registerLazySingleton<AdviceRepository>(()=>AdviceRepository());
  locator.registerLazySingleton<ReportRepository>(()=>ReportRepository());
  locator.registerLazySingleton<FoodRepository>(()=>FoodRepository());
  locator.registerLazySingleton<DayRepository>(()=>DayRepository());
  locator.registerLazySingleton<UserRepository>(()=>UserRepository());
  locator.registerLazySingleton<RoutineRepository>(()=>RoutineRepository());
  locator.registerLazySingleton<JourneyRepository>(()=>JourneyRepository());
  locator.registerLazySingleton<ConversationRepository>(()=>ConversationRepository());
}