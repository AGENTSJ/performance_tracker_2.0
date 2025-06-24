import 'dart:convert';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/day.service.dart';

class CommentsService {
  final aiService = locator<AiService>();
  final dayService = locator<DayService>();

  Future<GeneratedComment> setDietComments(Day day) async
  {
    var previousComment = day.comments?.overallDietComments;
    
    if(previousComment == null)
    {
      var genComment =  await _generateDietComment(day);

      // dayService.updateDayData(day);
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
        return await _generateDietComment(day);
      }
    }
  }

  Future<GeneratedComment> _generateDietComment(Day day) async
  {
    const CONTEXT_LIMIT_DAYS = 7;
    String contextInformation = '';
    var currMacroStructure = dayService.getDaysCalories(day);
    String todayMacroStructure = "${dayService.getDateString(day.dayTime)} : ${jsonEncode(currMacroStructure)}";
    for(var i = 1;i<CONTEXT_LIMIT_DAYS;i++)
    {
      Day? currDay = await dayService.getDayDataByDate(day.dayTime.subtract(Duration(days: i)));
      String macroStructureOnTheDay = jsonEncode(dayService.getDaysCalories(currDay!));
      contextInformation+="${dayService.getDateString(currDay.dayTime)} : ${macroStructureOnTheDay}";
    }
    const String instructions = 'You are a diet coach your responsibility is to help user to be healthy and helping them acheiving theri goals by means of nutrition the data can conatin last 7 days of data this application is an calorie counter app and some times the user can be new or the user can forget to log data on some days so respond apt for both see';
    String prompt = '''here is todays macros user has added till now time now is ${DateTime.now()}  $todayMacroStructure And the users past week data is here as follows $contextInformation your response is shown when user logs on the application guide user and prepare them mentally and give them small tips based on the data provided''';

    var response = await aiService.getResponse(prompt, instructions);
    var resString = response['candidates'][0]['content']['parts'][0]['text']; 
    GeneratedComment genComment = GeneratedComment(comment: resString, timeOfGeneration: DateTime.now(), macrosAtGenTime: currMacroStructure);
    return genComment;
  }
}