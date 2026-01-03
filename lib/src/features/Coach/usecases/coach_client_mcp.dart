import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/coach_server_dto.dart';
import 'package:performance_tracker/src/features/Coach/usecases/coach_server.mcp.dart';

class CoachClientMcp {
  final aiService = locator<AiService>();
  final coachServer = locator<CoachServerMcp>();
  bool adviceClientPipeIsActive = false;
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
    addRoutine, 
    updateRoutine,
    addWorkout,
    updateWorkout,

  Tool description 

    1 updateAdvices : takes {advices: [
    {
      "title": "string - onGoing ",(current active advices) 
      "advices": [
        {
          "adviceDesc": "string - detailed advice text",
          "conditions": "string - when or under what conditions this advice applies",
          "title": "string - short advice title",
        }
      ],
      "type": "string onGoing"
    },
    {
      "title": "string - Worked", (advices that has been sure have been worked on user),
      "advices": [
        {
          "adviceDesc": "string - detailed advice text",
          "conditions": "string - when or under what conditions was given and why it worked",
          "title": "string - short advice title",
        }
      ],
      "type": "string - worked "
    },
    {
      "title": "string - Not Worked", (advices that has proven to not work)
      "advices": [
        {
          "adviceDesc": "string - detailed advice text",
          "conditions": "string - when or under what conditions this advice applied and why it didn't work",
          "title": "string - short advice title",
        }
      ],
      "type": "string - notWorked"
    }
  ]} NOTE: YOUR RESPONSE PARAMETER FOR THIS TOOL SHOULD CONTAIN THE UPDATED SET ALONG WITH THE NEWLY ADDED AND PREVIOUS IF ANY CHANGES OR SHIFTS THE UPDATED SET
  
  2 addRoutine : takes parameters {'routineName': string - name for the routine ,'routineDesc' :'short description of routine' ,'newWorkouts':[workout object],'workoutIds':[id of  workouts if they exist (int)]}
  
  3 updateRoutine : takes parameters {'routineKey' : 'existing id of routine','newWorkouts':[workout object],'workoutIds':[id of  workouts if they exist (int)]}
  Note : the workout ids list is the updated list that is if any added the workoutIds have the new one along with old ones
  newWorkouts is where if the workout doesn't exist in the app u can create one
    Note an workout should not have sets of same kg multiple times since they are for progress tracking if u need to ask user to do multiple sets with same kg update in description that is workout journal
    all keys must have default value if not significant for parsing plus sets value kg is unique for workout meaning the two sets of sma e value must not exist within a workout
    Workout object structure {
      "key" : int (not required for creating of new workout)
      "name": "String - name of the workout",
      "sets": [
        {
          "value": "Double - Kg unit of set",
          "history": [
            {
              "entryDate": "String (ISO 8601 DateTime) - date of the logged entry",
              "value": "Integer - recorded value (e.g., reps)"
            }
          ],
          "pr": "Integer - personal record for the set",
          "enabled": "Boolean - whether this set is active"
        }
      ],
      "enabled": "Boolean - whether the workout is active",
      "desc": "String - description of the workout",
      "volumes": [
        {
          "muscleName": "String - name of the muscle group",
          "volume": "Double - total training volume for that muscle"
        }
      ]
    }
    Note muscleName can be of ${TRAINABLE_MUSCLES.join(',')}
  4 addWorkout takes : {'workout':workout object} without key attribute 
  
  5 updateWorkout takes : {'workoutId': int key of workout, 'workout': updated workout object with key attribute } make sure not to remove a set if u dont want user to do 
  an set make enabled false 
  above tools if 
  NOTE : Your response should be in json and nothing else is required adhere to payload structure at all time
  ''';

  Future<void> coachAct(String desc) async {
    if (adviceClientPipeIsActive == true) {
      Fluttertoast.showToast(
        msg: "An another advice is getting applied wait few moments",
      );
      return;
    }
    try {
      String knowledge = await coachServer.getKnowledgeBase();
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
                    "Task : Use tools to make the given description possible $desc knowledge base : $knowledge",
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
    } catch (e) {
      rethrow;
    } finally {
      adviceClientPipeIsActive = false;
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
      case CoachServerTools.addWorkout:
        await coachServer.addWorkout(
          Workout.fromJson(received.parameters["workout"]) 
        );
        return;
      case CoachServerTools.updateWorkout:
        await coachServer.updateWorkout(
            received.parameters['workoutId'],
            Workout.fromJson(received.parameters["workout"])
          );
        return;
      case CoachServerTools.addRoutine:
        await coachServer.addRoutine(
          routineName: received.parameters["routineName"],
          routineDesc: received.parameters["routineDesc"],
          newWorkouts: (received.parameters["newWorkouts"] as List<dynamic>)
              .map((w) => Workout.fromJson(w))
              .toList(),
          workoutIds: (received.parameters["workoutIds"] as List<dynamic>).map((i)=>int.parse(i.toString())).toList(),
        );
        break;
      case CoachServerTools.updateRoutine:
        await coachServer.updateRoutine(
          routineKey: received.parameters["routineKey"],
          newWorkouts: (received.parameters["newWorkouts"] as List<dynamic>)
              .map((w) => Workout.fromJson(w))
              .toList(),
          workoutIds: (received.parameters["workoutIds"] as List<dynamic>).map((i)=>int.parse(i.toString())).toList(),
        );
        return;
    }
  }
}
