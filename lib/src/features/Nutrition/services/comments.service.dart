import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/core/models/day.model.dart';
import 'package:performance_tracker/core/models/food.model.dart';
import 'package:performance_tracker/core/models/user.model.dart';
import 'package:performance_tracker/core/services/ai.service.dart';
import 'package:performance_tracker/core/services/day.service.dart';
import 'package:performance_tracker/core/services/user.service.data.dart';
import 'package:performance_tracker/core/services/userGoals.service.dart';

class CommentsService {
  final aiService = locator<AiService>();
  final dayService = locator<DayService>();
  final userGoalService = locator<UserGoalsService>();
  final userService = locator<UserService>();
  final TIME_DIFF_TRIGGER_MINUTES = 60;
  final CAL_DIFF_TRIGGER = 500;
  final CONTEXT_LIMIT_DAYS = 7;
  String userAccountCreatedDate = "";
  String UserGoalDescription = "";

  UserGoals? userGoals ;
  User? user;
  CommentsService()
  {
    Future.microtask(
      ()async
      {
        userGoals = await userGoalService.getUserGoals();
        user = await userService.getUserData();
        userAccountCreatedDate = "${user!.createdAt}";
        UserGoalDescription = "User is currently at ${user!.weight}kg and has a goal to reach ${userGoals!.targetWeight}kg Todays target calories is ${userGoals!.calorieLimit}";
      }
    );
  }
  
  Future<GeneratedComment?> setDietComments(Day day) async
  {
    var previousComment = day.comments?.overallDietComments;
    if(previousComment == null)
    {
      if(dayService.getDateString(day.dayTime)!=dayService.getDateString(DateTime.now()) )
      {
        return null;
      }
      var genComment =  await _generateDietComment(day);
      if(genComment == null)
      {
        return GeneratedComment(comment: 'Sorry, I am not able to respond now. Please try again later.', timeOfGeneration: DateTime.now(), macrosAtGenTime: MacroNutrients( 0, 0,  0, 0,0));
      }
      day.comments ??=  DayComments();
      day.comments!.overallDietComments = genComment;
      dayService.updateDayData(day);
      return genComment;
    }
    else
    {
      MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);
      MacroNutrients prevMacroStructure = previousComment.macrosAtGenTime;
      double calDiff = (currentMacroStructure.calories - prevMacroStructure.calories).abs();

      if(calDiff < CAL_DIFF_TRIGGER)
      {
        return previousComment;
      }
      else
      {
        var genComment = await _generateDietComment(day);
        if(genComment == null)
        {
          return GeneratedComment(comment: 'Sorry, I am not able to respond now. Please try again later.', timeOfGeneration: DateTime.now(), macrosAtGenTime: MacroNutrients( 0, 0,  0, 0,0));
        }
        day.comments!.overallDietComments = genComment;
        dayService.updateDayData(day);
        return genComment;

      }
    }
  }

  Future<GeneratedComment?> _generateDietComment(Day day) async
  {
    String contextInformation = '';
    var currMacro = dayService.getDaysCalories(day);
    var currMacroStructure = currMacro.toJson();
    String todayMacroStructure = "${dayService.getDateString(day.dayTime)} : ${jsonEncode(currMacroStructure)}";
    for(var i = 1;i<CONTEXT_LIMIT_DAYS;i++)
    {
      Day? currDay = await dayService.getDayDataByDate(day.dayTime.subtract(Duration(days: i)));
      String macroStructureOnTheDay = jsonEncode(dayService.getDaysCalories(currDay!).toJson());
      contextInformation+="${dayService.getDateString(currDay.dayTime)} : $macroStructureOnTheDay";
    }

    const String instructions = '''
    You are a diet coach
    Your responsibility 
    1. Greet user (good morning etc based on the current time)
    2. Comment on users macro Nutrients that they have taken for the day
    3. Comment on past days performance compliment or provide support 
    Note 
    1. DO NOT USE ANY MARK DOWN ANNOTATIONS (** **)
    2. THE RESPONSE SHOULD LOOK LIKE A TEXT MESSAGE (Keep it short , like a funny caring friend not too short not too long)
    3. use emojis 
    4. Dont have to include calorie count and other things specific things in your response unless user asks for it
    5. An empty context information or gaps in them mean user has not been tracking consistently or the user has recently created the account
    ''';
    String prompt = '''
    Today is ${DateTime.now()},
    User created the account on $userAccountCreatedDate,
    Day on which user has provided to comment on is ${day.dayTime},
    Users macro structure till now $todayMacroStructure,
    Users past day context $contextInformation
    ''';
    var response = await aiService.getResponse(prompt, instructions);
    if(!response.success)
    {
      return null;
    }
    var resString = response.message; 
    GeneratedComment genComment = GeneratedComment(comment: resString, timeOfGeneration: DateTime.now(), macrosAtGenTime: currMacro);
    return genComment;
  }

  Future<GeneratedComment?> setMacroComments(Day day) async
  {
    var previousComment = day.comments?.macroNutrientsComments;

    if(previousComment == null)
    {
      if(dayService.getDateString(day.dayTime)!=dayService.getDateString(DateTime.now()) )
      {
        return null;
      }
      var genComment =  await _generateMacroComment(day);
      if(genComment == null)
      {
        return GeneratedComment(comment: 'Sorry, I am not able to respond now. Please try again later.', timeOfGeneration: DateTime.now(), macrosAtGenTime: MacroNutrients( 0, 0,  0, 0,0));
      }
      day.comments ??=  DayComments();
      day.comments!.macroNutrientsComments = genComment;
      dayService.updateDayData(day);
      return genComment;
    }
    else
    {
      MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);
      MacroNutrients prevMacroStructure = previousComment.macrosAtGenTime;
      String currentMacroSignature = jsonEncode(currentMacroStructure);
      String prevMacroSignature = jsonEncode(prevMacroStructure);

      if(currentMacroSignature == prevMacroSignature)
      {
        return previousComment;
      }
      else
      {
        var genComment = await _generateMacroComment(day);
        if(genComment == null)
        {
          return GeneratedComment(comment: 'Sorry, I am not able to respond now. Please try again later.', timeOfGeneration: DateTime.now(), macrosAtGenTime: MacroNutrients( 0, 0,  0, 0,0));
        }
        day.comments!.macroNutrientsComments = genComment;
        dayService.updateDayData(day);
        return genComment;

      }
    }
  }

  Future<GeneratedComment?> _generateMacroComment(Day day) async
  {
    const String instruction = '''
    Your responsibilities 
    1 analyze users macro distribution 
    2 provide tips and tricks on how user can improve and achieve their goal
    3 suggest foods that help user to achieve their goal and health
    Note
    1. DO NOT USE ANY MARK DOWN ANNOTATIONS (** **)
    2. THE RESPONSE SHOULD LOOK LIKE A TEXT MESSAGE (Keep it short , like a funny caring friend not too short not too long)
    3. use emojis 
    4. Dont have to include calorie count and other things specific things in your response unless user asks for it
    5. An empty context information or gaps in them mean user has not been tracking consistently or the user has recently created the account
    6. FOCUS ON THE MACRO NUTRIENT PROFILE ONLY FOR THIS RESPONSE
    ''';
    MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);
    String currentMacroSignature = jsonEncode(currentMacroStructure);
    String prompt = '''
    Users goal is $UserGoalDescription,
    User has an macro structure as follows $currentMacroSignature 
    Suggest user foods that help them to achieve their goal and health
    ''';
    var responseObject = await aiService.getResponse(prompt, instruction);
    if(!responseObject.success)
    {
      return null;
    }
    var resString = responseObject.message; 
    GeneratedComment genComment = GeneratedComment(comment: resString, timeOfGeneration: DateTime.now(), macrosAtGenTime: currentMacroStructure);
    return genComment;
  }

  Future<GeneratedComment?> setMicroComments(Day day,Map<String, MeasuredUnit> microMap) async
  {
    var previousComment = day.comments?.microNutrientsComments;
    if(previousComment == null)
    {
      if(dayService.getDateString(day.dayTime)!=dayService.getDateString(DateTime.now()) )
      {
        return null;
      }
      var genComment =  await _generateMicroComment(day,microMap);
      if(genComment == null)
      {
        return GeneratedComment(comment: 'Sorry, I am not able to respond now. Please try again later.', timeOfGeneration: DateTime.now(), macrosAtGenTime: MacroNutrients( 0, 0,  0, 0,0));
      }
      day.comments ??=  DayComments();
      day.comments!.microNutrientsComments = genComment;
      dayService.updateDayData(day);
      return genComment;
    }
    else
    {
      MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);
      MacroNutrients prevMacroStructure = previousComment.macrosAtGenTime;
      String currentMacroSignature = jsonEncode(currentMacroStructure);
      String prevMacroSignature = jsonEncode(prevMacroStructure);

      if(currentMacroSignature == prevMacroSignature)
      {
        return previousComment;
      }
      else
      {
        var genComment = await _generateMicroComment(day,microMap);
        if(genComment == null)
        {
          return GeneratedComment(comment: 'Sorry, I am not able to respond now. Please try again later.', timeOfGeneration: DateTime.now(), macrosAtGenTime: MacroNutrients( 0, 0,  0, 0,0));
        }
        day.comments!.microNutrientsComments = genComment;
        dayService.updateDayData(day);
        return genComment;

      }
    }
  }

   Future<GeneratedComment?> _generateMicroComment(Day day , Map<String, MeasuredUnit> microMap) async
  {
    const String instruction = '''
    Your responsibilities 
    1 analyze users micro nutrient distribution 
    2 provide tips and tricks on how user can improve and achieve their goal
    3 suggest foods that help user to achieve their goal and health
    Note
    1. DO NOT USE ANY MARK DOWN ANNOTATIONS (** **)
    2. THE RESPONSE SHOULD LOOK LIKE A TEXT MESSAGE (Keep it short , like a funny caring friend not too short not too long)
    3. use emojis 
    4. Dont have to include calorie count and other things specific things in your response unless user asks for it
    5. An empty context information or gaps in them mean user has not been tracking consistently or the user has recently created the account
    6. FOCUS ON THE MICRO NUTRIENT PROFILE ONLY FOR THIS RESPONSE
    ''';
    MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);

    String currentMicroSignature = _convertMicroMapToString(microMap);
    
    String prompt = '''
    Users goal is $UserGoalDescription,
    User has an micro structure as follows $currentMicroSignature 
    Suggest user foods that help them to achieve their goal and health
    ''';
    var responseObject = await aiService.getResponse(prompt, instruction);
    if(!responseObject.success)
    {
      return null;
    }
    var resString = responseObject.message; 
    GeneratedComment genComment = GeneratedComment(comment: resString, timeOfGeneration: DateTime.now(), macrosAtGenTime: currentMacroStructure);
    return genComment;
  }


  _convertMicroMapToString(Map<String, MeasuredUnit> microMap)
  {
    String res= '';

    for (var micro in microMap.entries) {
      res+='''${micro.key}:{ value:${micro.value.value},unit:${micro.value.unit}}\n,''';
    }
    return res;
  }
}