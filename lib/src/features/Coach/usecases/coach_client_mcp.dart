import 'dart:convert';

import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/coach_server_dto.dart';
import 'package:performance_tracker/src/features/Coach/usecases/coach_server.mcp.dart';

class CoachClientMcp {
  final aiService = locator<AiService>();
  final coachServer = locator<CoachServerMcp>();
  final stringServerToolDesc = '''
  You are a client who are going to produce an payload your payload structure would look like
  {
    'actions':[
      {
        'tool':'tool name',
        'parameters:'parameter object specific to the tool not an list the object structure would be defined bellow in tool description' 
      }
    ]
  }
  actions should be tools that u will require to achieve a certain task
  Server has tools 
    updateAdvices,
    addWorkout,
    updateWorkout, 

  Tool description 
    updateAdvices takes :{advices: [
    {
      "title": "string - name of the advice set",
      "advices": [
        {
          "adviceDesc": "string - detailed advice text",
          "conditions": "string - when or under what conditions this advice applies",
          "title": "string - short advice title",
        }
      ],
      "type": "string - one of: worked | onGoing | notWorked"
    }
  ]}
  Other tools are not yet implemented
  
  NOTE : Your response should be in json and nothing else is required adhere to payload structure at all time
  ''';

  Future<void> coachAct(String? title, String desc) async {
    String knowledge = coachServer.getKnowledgeBase();
    AiChatContent payload = AiChatContent(
      system_instruction: AiChatSegment(
        role: null,
        parts: [ChatPart(text: stringServerToolDesc)],
      ),
      contents: [
        AiChatSegment(
          role: null,
          parts: [
            ChatPart(
              text:
                  "Task : Use tools to make this advice possible, advice title if any $title , advice details if any $desc knowledge base : $knowledge",
            ),
          ],
        ),
      ],
    );
    var response = await aiService.getResponse2(payload);
    var data = aiService.removeJsonAnnotation(response.message);
    var json = jsonDecode(data);
    var actionList = json["actions"];

    for (var action in actionList) {
      var actionObj = ServerProtocolDTO.fromJson(action);
      await act(actionObj);
    }
  }

  Future<dynamic> act(ServerProtocolDTO received) async {
    switch (received.tool) {
      case CoachServerTools.updateAdvices:
        List<AdviceSet> sets = (received.parameters['advices'] as List<dynamic>)
            .map((advset) => AdviceSet.fromJson(advset))
            .toList();
        await coachServer.updateAdviceSets(advices: sets);
        return;
      case CoachServerTools.removeAdvice:
        break;
      case CoachServerTools.addWorkout:
        break;
      case CoachServerTools.updateWorkout:
        break;
    }
  }

}
