import 'dart:convert';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/day.service.dart';

class CommentsService {
  final aiService = locator<AiService>();
  final dayService = locator<DayService>();

  Future<GeneratedComment?> setDietComments(Day day) async
  {
    var previousComment = day.comments?.overallDietComments;
    const TIME_DIFF_TRIGGER_MINUTES = 60;

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
    const CONTEXT_LIMIT_DAYS = 7;
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
    String prompt = '''here is todays macros user has added till now time now is ${DateTime.now()} and the day user gave to comment is ${day.dayTime} and macros is $todayMacroStructure And the users past week data is here as follows $contextInformation your response is shown when user logs on the application guide user Greet them and give a tip if they are doing well if not consolidate them keep it short as like a small talk dont include calorie count exact in the response ''';

    var response = await aiService.getResponse(prompt, instructions);
    var resString = response['candidates'][0]['content']['parts'][0]['text']; 
    GeneratedComment genComment = GeneratedComment(comment: resString, timeOfGeneration: DateTime.now(), macrosAtGenTime: currMacro);
    return genComment;
  }
}