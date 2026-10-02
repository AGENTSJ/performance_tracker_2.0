import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Workout/models/advice.model.dart';
import 'package:performance_tracker/src/features/Coach/repositories/conversation.respository.dart';
import 'package:performance_tracker/src/features/Workout/services/advice.service.dart';
import 'package:performance_tracker/core/services/ai.service.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Dashboard/services/journey.service.dart';
import 'package:performance_tracker/src/features/Coach/services/report.service.dart';
import 'package:performance_tracker/src/features/Workout/services/routine.service.dart';
import 'package:performance_tracker/core/services/user.service.data.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/chat.models.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';

/// Live progress of an in-flight coach chat reply. Held in the
/// [TrainerAgentService] singleton (in memory, not persisted) so a response
/// keeps streaming even when the user navigates away from the coach page, and
/// is restored when they return.
class CoachChatProgress {
  /// Whether the coach is currently producing a reply.
  final bool isResponding;
  /// Cumulative thinking/answer text streamed from the model so far.
  final String thinking;
  /// The user message being answered; shown as a transient bubble until the
  /// exchange is committed to the conversation history.
  final String pendingUserMessage;
  const CoachChatProgress({
    required this.isResponding,
    this.thinking = '',
    this.pendingUserMessage = '',
  });
  const CoachChatProgress.idle()
      : isResponding = false,
        thinking = '',
        pendingUserMessage = '';

  CoachChatProgress copyWith({
    bool? isResponding,
    String? thinking,
    String? pendingUserMessage,
  }) => CoachChatProgress(
        isResponding: isResponding ?? this.isResponding,
        thinking: thinking ?? this.thinking,
        pendingUserMessage: pendingUserMessage ?? this.pendingUserMessage,
      );
}

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

  /// Observable, centralised state of the in-flight chat reply. Survives
  /// navigation because [TrainerAgentService] is a singleton.
  final ValueNotifier<CoachChatProgress> chatProgress =
      ValueNotifier(const CoachChatProgress.idle());
  CancelToken? _chatCancelToken;
  bool get isResponding => chatProgress.value.isResponding;

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
    if(journey==null)
    {
      return "No active journey";
    }
    var user = await _userService.getUserData();
    var caloriesTotal =
        (journey.userAtStart.weight - user.userGoals.targetWeight).abs() *
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

  /// Streaming chat reply whose progress is centralised in [chatProgress] so it
  /// survives the user leaving and returning to the coach page. Fire-and-forget:
  /// the UI observes [chatProgress] rather than awaiting the result. Uses the
  /// user-selected Gemini model. The user message and the reply are only
  /// committed to the conversation history once the reply succeeds, so an
  /// aborted/failed reply leaves no dangling user message on disk (and no
  /// duplicate bubble when the page is rebuilt mid-flight).
  Future<void> sendCoachMessage(String message) async {
    if (isResponding) return;
    _chatCancelToken = CancelToken();
    chatProgress.value =
        CoachChatProgress(isResponding: true, pendingUserMessage: message);
    try {
      var old = await getOlderChat();
      final userSegment = AiChatSegment(
        role: ChatRoles.user,
        parts: [ChatPart(text: message)],
      );
      // Build the request history without mutating the persisted conversation.
      final history = [...old.contents, userSegment];
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
                  '''Your role is of an Training coach\nplatform provides\n\t1 calorie tracking\n\t2 workout creation and progress tracking reps and sets\n\t3 activity tracking\nYour context\n\t1 Workout Context : $workoutContext\n\t2 Physique & Nutrition Context : $nutritionNdBodyContext\n\t3 Journey context : $journeyContext\n\t3 Advice context : $advContext\nYou have 2 modes\n\t1 Advice mode\n\t\tin this mode you are taking big responsibility you must carefully take in all information form user and provide Quantitative advices,\n\t\tas this is a fitness platform your advices such be such , and the platform must support these advices ,DO NOT GIVE advices for the sake of giving advice,\n\t\tsince these advices determine users progress , at the same time due to the known fact that every person is unique you should try experiments with user on the basis of training , nutrition in a way that the platform supports it , and hence some times you can find advices to be not effective and hence you should also advice user to update the status of advice and u cannot do that on ur own u should advice, when you respond in advice mode make sure you include 'Here is your advice' then proceed with precise and well directed quantitative advices for an example 'lets add x more volume to chest training ' or 'lets reduce x volume from chest training' this is an example direct user based on what you think the best advice would be make sure u give only advices and no jargons of sugar coating in advice response\n\t2 Normal mode\n\t\tyou chat with user and know user more and be coach also a good supportive person\nNote the above is not part of the chat that u are going to have with user this is for you to keep in mind''',
            ),
          ],
        ),
        contents: history,
      );
      var selectedModel = await _aiService.getSelectedModel();
      var response = await _aiService.getResponseStream2(
        content,
        modelName: selectedModel,
        cancelToken: _chatCancelToken,
        onProgress: (thoughts, answer) {
          chatProgress.value = chatProgress.value.copyWith(
            thinking: thoughts.isNotEmpty ? thoughts : answer,
          );
        },
      );

      if (!response.success) {
        // A user-initiated cancel is silent; anything else is a real error.
        if (_chatCancelToken?.isCancelled != true) {
          Fluttertoast.showToast(msg: "An error has occur");
        }
        return;
      }
      // Commit the exchange now that we have a full reply.
      old.contents.add(userSegment);
      old.contents.add(
        AiChatSegment(
          role: ChatRoles.model,
          parts: [ChatPart(text: response.message)],
        ),
      );
      await _conversationRepo.updateConversation(old.key, old);
    } catch (e) {
      Fluttertoast.showToast(msg: "An error has occur");
    } finally {
      _chatCancelToken = null;
      chatProgress.value = const CoachChatProgress.idle();
    }
  }

  /// Aborts the in-flight chat reply (if any). The streamed request is torn down
  /// and nothing is committed to history.
  void cancelChat() {
    _chatCancelToken?.cancel();
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
                  '''Your role is of an Training coach\nplatform provides\n\t1 calorie tracking\n\t2 workout creation and progress tracking reps and sets\n\t3 activity tracking\nYour context\n\t1 Workout Context : $workoutContext\n\t2 Physique & Nutrition Context : $nutritionNdBodyContext\n\t3 Journey context : $journeyContext\n\t3 Advice context : $advContext\nYou have 2 modes\n\t1 Advice mode\n\t\tin this mode you are taking big responsibility you must carefully take in all information form user and provide Quantitative advices,\n\t\tas this is a fitness platform your advices such be such , and the platform must support these advices ,DO NOT GIVE advices for the sake of giving advice,\n\t\tsince these advices determine users progress , at the same time due to the known fact that every person is unique you should try experiments with user on the basis of training , nutrition in a way that the platform supports it , and hence some times you can find advices to be not effective and hence you should also advice user to update the status of advice and u cannot do that on ur own u should advice, when you respond in advice mode make sure you include 'Here is your advice' then proceed with precise and well directed quantitative advices for an example 'lets add x more volume to chest training ' or 'lets reduce x volume from chest training' this is an example direct user based on what you think the best advice would be make sure u give only advices and no jargons of sugar coating in advice response\n\t2 Normal mode\n\t\tyou chat with user and know user more and be coach also a good supportive person\nNote the above is not part of the chat that u are going to have with user this is for you to keep in mind''',
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
