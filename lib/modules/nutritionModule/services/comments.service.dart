import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/modules/nutritionModule/models/day.model.dart';
import 'package:performance_tracker/modules/nutritionModule/models/food.model.dart';
import 'package:performance_tracker/modules/sharedModule/services/ai.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/day.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/userGoals.service.dart';

class CommentsService {
  final aiService = locator<AiService>();
  final dayService = locator<DayService>();
  final userGoalService = locator<UserGoalsService>();
  final TIME_DIFF_TRIGGER_MINUTES = 60;
  final CAL_DIFF_TRIGGER = 500;
  final CONTEXT_LIMIT_DAYS = 7;
  String UserGoalDescription = "";

  Map<String,dynamic>? userGoals ;
  CommentsService()
  {
    Future.microtask(
      ()async
      {
        userGoals = await userGoalService.getUserGoals();
        UserGoalDescription = '''
        Users maintenance calories is ${userGoals?["maintenanceCalories"]}
        User wants to reduce weight 
        ''';
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
      day.comments ??=  DayComments();
      day.comments!.overallDietComments = genComment;
      dayService.updateDayData(day);
      return genComment;
    }
    else
    {
      MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);
      MacroNutrients prevMacroStructure = previousComment.macrosAtGenTime;
      // String currentMacroSignature = jsonEncode(currentMacroStructure);
      // String prevMacroSignature = jsonEncode(prevMacroStructure);
      Duration timeDiff = DateTime.now().difference(previousComment.timeOfGeneration);

      double calDiff = (currentMacroStructure.calories - prevMacroStructure.calories).abs();

      if(calDiff < CAL_DIFF_TRIGGER && timeDiff.inMinutes < TIME_DIFF_TRIGGER_MINUTES)
      {
        return previousComment;
      }
      else
      {
        var genComment = await _generateDietComment(day);
        day.comments!.overallDietComments = genComment;
        dayService.updateDayData(day);
        return genComment;

      }
    }
  }

  Future<GeneratedComment> _generateDietComment(Day day) async
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
    const String instructions = 'You are a diet coach your responsibility is to help user to be healthy and helping them achieving their goals by means of nutrition the data can contain last 7 days of data this application is an calorie counter app and some times the user can be new or the user can forget to log data on some days so respond apt for both see DO NOT PROVIDE ANY ANNOTATIONS FOR MARK DOWN as this must look like a text but feel free to provide line breaks where it could improve readability emojis are also welcomed if needed do not over use any';
    String prompt = '''${UserGoalDescription} here is todays macros user has added till now time now is ${DateTime.now()} and the day user gave to comment is ${day.dayTime} and macros is $todayMacroStructure And the users past week data is here as follows $contextInformation your response is shown when user logs on the application guide user Greet them and give a tip if they are doing well if not consolidate them keep it short as like a small talk dont include calorie count exact in the response ''';

    var response = await aiService.getResponse(prompt, instructions);
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
      // Duration timeDiff = DateTime.now().difference(previousComment.timeOfGeneration);

      if(currentMacroSignature == prevMacroSignature)
      {
        return previousComment;
      }
      else
      {
        var genComment = await _generateMacroComment(day);
        day.comments!.macroNutrientsComments = genComment;
        dayService.updateDayData(day);
        return genComment;

      }
    }
  }

  Future<GeneratedComment> _generateMacroComment(Day day) async
  {
    const String instruction = '''
    You are a diet coach. You are given the user's macronutrient distribution for the day.
    Review the values and suggest how the user can improve their diet to better achieve their goals.
    If their macronutrient intake is good, compliment them.
    Keep your response short, unless a longer explanation is necessary for the situation.
    Do NOT use markdown notations (such as ** **).
    Write your response as if you are talking to the user.
    Use emojis if appropriate, and use line breaks where it improves readability, but do not overdo it.
    You do not need to repeat the user's current status, as it is visible in the UI.
    ''';
    MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);
    String currentMacroSignature = jsonEncode(currentMacroStructure);
    String prompt = '''
    Users goal is ${UserGoalDescription},
    User has an macro structure as follows $currentMacroSignature 
    Suggest user foods that help them to acheive their goal and health
    ''';
    var responseObject = await aiService.getResponse(prompt, instruction);
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
        var genComment = await _generateMacroComment(day);
        day.comments!.macroNutrientsComments = genComment;
        dayService.updateDayData(day);
        return genComment;

      }
    }
  }

   Future<GeneratedComment> _generateMicroComment(Day day , Map<String, MeasuredUnit> microMap) async
  {
    const String instruction = '''
    You are a diet coach. You are given the user's micronutrient distribution. 
    Review the values and suggest how the user can improve their diet to better achieve their goals. 
    If their micronutrient intake is good, compliment them. 
    Keep your response short, unless a longer explanation is necessary for the situation. 
    Do NOT use markdown notations (such as ** **). 
    Write your response as if you are talking to the user. 
    Use emojis if appropriate, and use line breaks where it improves readability, but do not overdo it. 
    You do not need to repeat the user's current status, as it is visible in the UI.
    ''';
    MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);

    String currentMicroSignature = _convertMicroMapToString(microMap);
    
    String prompt = '''
    Users goal is ${UserGoalDescription},
    User has an micro structure as follows $currentMicroSignature 
    Suggest user foods that help them to acheive their goal and health
    ''';
    var responseObject = await aiService.getResponse(prompt, instruction);
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