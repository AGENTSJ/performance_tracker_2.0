import 'dart:async';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/repositories/conversation.respository.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';

class ChatStreamDTO
{
  String streamData;
  StreamController<AiResponse> stream;
  StreamController<String>? eventStream;
  ChatStreamDTO({required this.stream,required this.streamData,required this.eventStream});
}
class TrainerAgentService {
  final _aiService = locator<AiService>();
  final _routineService = locator<RoutineService>();
  final reportService = locator<ReportService>();
  final _convRepo = locator<ConversationRepository>();
  StreamController<AiResponse>? _chatStreamInternal;
  StreamController<AiResponse>? _chatStreamExternal;
  String _chatRespData = "";
  bool pipeLineActive = false;
  
  Future<String> getPerformanceContext(DateTime? summaryFromDate) async {
    var routines = _routineService.getAllCustomRoutines();
    var summary = "";
    List<Future<Report>> futures = [];
    for (var rout in routines) {
      futures.add( reportService.getRoutineReport(rout, null,));
      break;
    }
    var results = await Future.wait(futures);
    for (var res in results) {
      summary += "${res.reportData} \n\n";
    }
    return summary;
  }

  Future<AiChatContent> getOlderChat()async
  {
    var convo = _convRepo.getAllConversations().lastOrNull;
    if(convo==null)
    {
      var key = await _convRepo.addConversation(AiChatContent(system_instruction: null, contents: []));
      convo = _convRepo.getConversationByKey(key);
    }
    return convo!;
  } 

  Future<void> clearAllChats()async
  {
    await _convRepo.clearAllChats();
  }

  Future<ChatStreamDTO> chatWithCoach(String message) async {
    if(!pipeLineActive)
    {
      _chatStreamExternal = StreamController<AiResponse>();
      String workoutContext = await getPerformanceContext(null);
      Report nutritionNdBodyContext = await reportService.getNutritionReport();
      AiChatContent content = AiChatContent(
        system_instruction: AiChatSegment(
          role: null,
          parts: [
            ChatPart(
              text:
                  "You are a training coach here is users data\nworkout context : $workoutContext\nNutrition and body context: ${nutritionNdBodyContext.reportData}",
            ),
          ],
        ),
        contents: [
          AiChatSegment(
            role: ChatRoles.user,
            parts: [ChatPart(text: message)],
          ),
        ],
      );
      _chatStreamInternal = await _aiService.streamGeminiResponse(content);
      _chatStreamInternal!.stream.listen(
        (data){
          _chatRespData+=data.message;
          _chatStreamExternal?.add(data);
        },
        onDone: () async{
          var old = await getOlderChat();
          old.contents.add(AiChatSegment(role: ChatRoles.user,parts:[ ChatPart(text: message)] ));
          old.contents.add(AiChatSegment(role: ChatRoles.model,parts:[ ChatPart(text: _chatRespData)] ));
          await _convRepo.updateConversation(old.key, old);
          _chatRespData = "";
          pipeLineActive = false;
          _chatStreamExternal?.close();
        },
        onError: (errObj){
          pipeLineActive = false;
          _chatRespData = "";
        }
      );
    }
    return ChatStreamDTO(stream: _chatStreamExternal!,streamData: _chatRespData,eventStream: null);
  }
}
