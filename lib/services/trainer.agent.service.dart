import 'dart:async';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/repositories/conversation.respository.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';

class ChatStreamDTO {
  String streamData;
  StreamController<AiResponse> stream;
  StreamController<String>? eventStream;
  ChatStreamDTO({
    required this.stream,
    required this.streamData,
    required this.eventStream,
  });
}

class TrainerAgentService {
  final _aiService = locator<AiService>();
  final _routineService = locator<RoutineService>();
  final reportService = locator<ReportService>();
  final _convRepo = locator<ConversationRepository>();
  StreamController<AiResponse>? _chatStreamInternal;
  StreamController<AiResponse>? chatStreamExternal;
  String chatRespData = "";
  bool pipeLineActive = false;

  Future<String> getPerformanceContext(DateTime? summaryFromDate) async {
    var routines = _routineService.getAllCustomRoutines();
    var summary = "";
    List<Future<Report>> futures = [];
    print("getting performance context");
    for (var rout in routines) {
      futures.add(reportService.getRoutineReport(rout, null));
      // break;
    }
    var results = await Future.wait(futures);
    for (var res in results) {
      summary += "${res.reportData} \n\n";
    }
    print("finished performance context");
    return summary;
  }

  Future<AiChatContent> getOlderChat() async {
    var convo = _convRepo.getAllConversations().lastOrNull;
    if (convo == null) {
      var key = await _convRepo.addConversation(
        AiChatContent(system_instruction: null, contents: []),
      );
      convo = _convRepo.getConversationByKey(key);
    }
    return convo!;
  }

  Future<void> clearAllChats() async {
    await _convRepo.clearAllChats();
  }

  Future<ChatStreamDTO> chatWithCoach(String message) async {
    if (!pipeLineActive) {
      pipeLineActive = true;
      chatStreamExternal = StreamController<AiResponse>();
      var old = await getOlderChat();
      old.contents.add(
        AiChatSegment(
          role: ChatRoles.user,
          parts: [ChatPart(text: message)],
        ),
      );
      String workoutContext = await getPerformanceContext(null);
      Report nutritionNdBodyContext = await reportService.getNutritionReport();
      AiChatContent content = AiChatContent(
        system_instruction: AiChatSegment(
          role: null,
          parts: [
            ChatPart(
              text:
                  "You are a training coach here is users data\nworkout context : $workoutContext\nNutrition and body context: ${nutritionNdBodyContext.reportData} above isn't part of the conversation you are going to have with user its something u should keep in ind before answering any advice prompts from user",
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
            chatStreamExternal?.add(data);
          },
          onDone: () async {
            old.contents.add(
              AiChatSegment(
                role: ChatRoles.model,
                parts: [ChatPart(text: chatRespData)],
              ),
            );
            await _convRepo.updateConversation(old.key, old);
            chatRespData = "";
            pipeLineActive = false;
            chatStreamExternal?.close();
          },
          onError: (errObj) {
            pipeLineActive = false;
            chatRespData = "";
          },
        );
      });
    }
    return ChatStreamDTO(
      stream: chatStreamExternal!,
      streamData: chatRespData,
      eventStream: null,
    );
  }
}
