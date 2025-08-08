import 'dart:async';
import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/repositories/conversation.respository.dart';
import 'package:performance_tracker/services/advice.service.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/chat.models.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';

class TrainerAgentService {
  final _aiService = locator<AiService>();
  final _routineService = locator<RoutineService>();
  final _reportService = locator<ReportService>();
  final _conversationRepo = locator<ConversationRepository>();
  final _advService = locator<AdviceService>();
  final _journeyService = locator<JourneyService>();
  final _commonService = locator<CommonService>();
  final _userService = locator<UserService>();
  StreamController<AiResponse>? _chatStreamInternal;
  StreamController<AiResponse>? _chatStreamExternal;
  bool _streamPipeLineActive = false;
  StreamController<AiResponse>? get chatStreamExternal => _chatStreamExternal;
  bool get streamPipeLineActive => _streamPipeLineActive;
  String chatRespData = "";

  Future<String> getPerformanceContext(DateTime? summaryFromDate) async {
    var routines = _routineService.getAllCustomRoutines();
    var summary = "";
    List<Future<Report>> futures = [];
    print("getting performance context");
    for (var rout in routines) {
      futures.add(_reportService.getRoutineReport(rout, null));
      // break;
    }
    var results = await Future.wait(futures);
    for (var res in results) {
      summary += "${res.reportData} \n\n";
    }
    print("finished performance context");
    return summary;
  }

  Future<String> getAdviceContext() async {
    var advices = _advService.fetchAllAdvices();
    String worked = "";
    String notWorked = "";
    String ongoing = "";
    for (var advSet in advices) {
      for (var adv in advSet.advices) {
        String advRep =
            "Title:${adv.title}\nConditions why this advice was given : ${adv.conditions}\nWhat did user observed : ${adv.adviceDesc}\n\n";
        if (advSet.type == AdviceStatus.worked) {
          worked += advRep;
        }
        if (advSet.type == AdviceStatus.notWorked) {
          notWorked += advRep;
        }
        if (advSet.type == AdviceStatus.worked) {
          ongoing += advRep;
        }
      }
    }
    var advString =
        "Advices that had worked on user if any : $worked\n Advices that has not worked on user if any : $notWorked \nAdvices user is currently following if any $ongoing";
    return advString;
  }

  Future<String> getJourneyContext() async {
    var journey = _journeyService.getActiveJourney();
    var user = await _userService.getUserData();
    var caloriesTotal =
        (journey!.userAtStart.weight - user.userGoals.targetWeight).abs() *
        7700;
    var estimatedDays =
        ((caloriesTotal - journey.caloriesChangeAchieved) /
                journey.userAtStart.userGoals.caloricChangeGoal)
            .round()
            .abs();
    var stepsTotal = estimatedDays * journey.userAtStart.userGoals.stepGoal;
    var caloriesAchievePercent = _commonService
        .getPercentage(caloriesTotal, journey.caloriesChangeAchieved)
        .roundToDouble()
        .clamp(0, 100);
    var stepAchievePercent = _commonService
        .getPercentage(stepsTotal.toDouble(), journey.stepsWalked.toDouble())
        .roundToDouble()
        .clamp(0, 100);
    var journeyCompleted = (caloriesAchievePercent + stepAchievePercent) / 2;

    var journeyContext =
        "Active journey data of use if any : Start date : ${_commonService.getDateString(journey.startDate)}\n User is supposed to burn a amount of calories and walk certain steps for the completion of journey percentage of calorie goal achieved  = $caloriesAchievePercent percentage of steps achieved $stepAchievePercent total journey completed $journeyCompleted";

    return journeyContext;
  }

  Future<AiChatContent> getOlderChat() async {
    var convo = _conversationRepo.getAllConversations().lastOrNull;
    if (convo == null) {
      var key = await _conversationRepo.addConversation(
        AiChatContent(system_instruction: null, contents: []),
      );
      convo = _conversationRepo.getConversationByKey(key);
    }
    return convo!;
  }

  Future<void> clearAllChats() async {
    await _conversationRepo.clearAllChats();
  }

  Future<ChatStreamDTO> chatWithCoachStream(String message) async {
    if (!_streamPipeLineActive) {
      _streamPipeLineActive = true;
      _chatStreamExternal = StreamController<AiResponse>.broadcast();
      var old = await getOlderChat();
      old.contents.add(
        AiChatSegment(
          role: ChatRoles.user,
          parts: [ChatPart(text: message)],
        ),
      );
      String workoutContext = await getPerformanceContext(null);
      String advContext = await getAdviceContext();
      String journeyContext = await getJourneyContext();
      Report nutritionNdBodyContext = await _reportService.getNutritionReport();
      AiChatContent content = AiChatContent(
        system_instruction: AiChatSegment(
          role: null,
          parts: [
            ChatPart(
              text:
                  "You are a training coach here is users data\nworkout context : $workoutContext\nNutrition and body context: ${nutritionNdBodyContext.reportData} Advices Context : $advContext Journey context : $journeyContext above isn't part of the conversation you are going to have with user its something u should keep in ind before answering any advice prompts from user",
            ),
          ],
        ),

        contents: old.contents,
      );
      _aiService.streamGeminiResponse(content).then((streamObject) {
        _chatStreamInternal = streamObject;
        _chatStreamInternal!.stream.listen(
          (data) {
            chatRespData += data.message;
            _chatStreamExternal?.add(data);
          },
          onDone: () async {
            old.contents.add(
              AiChatSegment(
                role: ChatRoles.model,
                parts: [ChatPart(text: chatRespData)],
              ),
            );
            await _conversationRepo.updateConversation(old.key, old);
            chatRespData = "";
            _streamPipeLineActive = false;
            _chatStreamExternal?.close();
          },
          onError: (errObj) {
            _streamPipeLineActive = false;
            chatRespData = "";
          },
        );
      });
    }
    return ChatStreamDTO(
      stream: _chatStreamExternal!,
      data: chatRespData,
      eventStream: null,
      advices: [],
    );
  }

  Future<ChatDTO?> chatWithCoach(String message) async {
    try {
      var old = await getOlderChat();
      old.contents.add(
        AiChatSegment(
          role: ChatRoles.user,
          parts: [ChatPart(text: message)],
        ),
      );
      String workoutContext = await getPerformanceContext(null);
      String advContext = await getAdviceContext();
      String journeyContext = await getJourneyContext();
      Report nutritionNdBodyContext = await _reportService.getNutritionReport();
      bool isAdviceMode = message.toLowerCase().contains('advice');
      AiChatContent content = AiChatContent(
        system_instruction: AiChatSegment(
          role: null,
          parts: [
            ChatPart(
              text:
                  "You are a training coach here is users data\nworkout context : $workoutContext\nNutrition and body context: ${nutritionNdBodyContext.reportData} Advices Context : $advContext Journey context : $journeyContext above isn't part of the conversation you are going to have with user its something u should keep in mind before answering any advice prompts from user, You have two modes one is acquire context , information support and motivate use the other one is a IMPORTANT ONE that is ADVICE mode this is where your response should analyze user and user context and give important and well defined and well directed quantified advices that the user should incorporated in their training you are a training coach and you should experiment with user based on previous worked and not worked advices and give out advices such as increase the set or reduce set if u see the need increase volume of muscle group if u find any advices that has not worked u want to advice user to remove the advice and ask them to shift this mode is no joke as this is the core of your role as again this should be descriptive",
            ),
          ],
        ),
        contents: old.contents,
      );
      var response = await _aiService.getResponse2(
        content,
        modelType: isAdviceMode ? Models.Pro : Models.Flash,
      );
      var respMessage = response.message;

      if (response.success) {
        old.contents.add(
          AiChatSegment(
            role: ChatRoles.model,
            parts: [ChatPart(text: respMessage)],
          ),
        );
        await _conversationRepo.updateConversation(old.key, old);
        return ChatDTO(data: respMessage, advices: []);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
