import 'dart:convert';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';

class CommentsService {
  final aiService = locator<AiService>();
  final dayService = locator<DayService>();
  final userGoalService = locator<UserGoalsService>();
  final TIME_DIFF_TRIGGER_MINUTES = 60;
  final CONTEXT_LIMIT_DAYS = 7;
  late final String UserGoalDescription;

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
      String currentMacroSignature = jsonEncode(currentMacroStructure);
      String prevMacroSignature = jsonEncode(prevMacroStructure);
      Duration timeDiff = DateTime.now().difference(previousComment.timeOfGeneration);

      if(currentMacroSignature == prevMacroSignature || timeDiff.inHours < TIME_DIFF_TRIGGER_MINUTES)
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
    var resString = response['candidates'][0]['content']['parts'][0]['text']; 
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
    const String instruction = '''You are a diet coach you must you are given the macro nutrient distribution of the the user that your should observe the values and suggest user how he can improve his diet if there is room for improvement to attain his or her goals if they are good compliment them too keep your output short and but if long is necessary considering the situation feel free to do so avoid markdown notation''';
    MacroNutrients currentMacroStructure = dayService.getDaysCalories(day);
    String currentMacroSignature = jsonEncode(currentMacroStructure);
    String prompt = '''
    Users goal is ${UserGoalDescription},
    User has an macro structure as follows $currentMacroSignature 
    ''';
    var responseObject = await aiService.getResponse(prompt, instruction);
    var resString = responseObject['candidates'][0]['content']['parts'][0]['text']; 
    GeneratedComment genComment = GeneratedComment(comment: resString, timeOfGeneration: DateTime.now(), macrosAtGenTime: currentMacroStructure);
    return genComment;
  }
}