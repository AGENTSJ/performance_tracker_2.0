import 'dart:async';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';


class TrainerAgentService {
  final _aiService = locator<AiService>();
  final _routineService = locator<RoutineService>();
  final reportService = locator<ReportService>();

  Future<String> getPerformanceContext(DateTime? summaryFromDate) async {
    var routines = _routineService.getAllCustomRoutines();
    var summary = "";
    List<Future<Report>> futures = [];
    for (var rout in routines) {
      futures.add( reportService.getRoutineReport(rout, null));
    }
    var results = await Future.wait(futures);
    for (var res in results) {
      summary += "${res.reportData} \n\n";
    }
    return summary;
  }

  Future<StreamController<AiResponse>?> chatWithCoach(String message) async {
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
    StreamController<AiResponse>? controller = await _aiService
        .streamGeminiResponse(content);
    return controller;
  }
}
