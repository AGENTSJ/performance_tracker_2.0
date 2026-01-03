import 'dart:async';
import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/key.service.dart';
import 'package:performance_tracker/services/log.service.dart';
import 'package:performance_tracker/services/rest.service.dart';
import 'package:http/http.dart' as http;
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';

enum Models { Pro, Flash }

class AiService {
  final _restService = locator<RestService>();
  final _logService = locator<LogService>();
  late Map<Models, _AI_Provider> _models;
  final keyService = locator<KeyService>();
  String API_KEY = '';
  final logKey = 'AI';

  AiService() {
    setModels();
  }
  setModels() async {
    API_KEY = await keyService.getAiApiKey() ?? '';
    var modelName = "gemini-2.0-flash";
    _models = {
      Models.Pro: _AI_Provider(
        apiKey: API_KEY,
        modelName: modelName,
        endpoint:
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$API_KEY",
      ),
      Models.Flash: _AI_Provider(
        apiKey: API_KEY,
        modelName: modelName,
        endpoint:
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$API_KEY",
      ),
    };
  }

  Future<AiResponse> getResponse(
    String promt,
    String? instructions, {
    Models modelType = Models.Flash,
  }) async {
    try {
      await setModels();
      _logService.addInfoLog(logKey, "Send Req ${modelType.toString()}");
      var model = _models[modelType];
      dynamic payload = {
        "system_instruction": {
          "parts": [
            {"text": instructions ?? ""},
          ],
        },
        "contents": [
          {
            "parts": [
              {"text": promt},
            ],
          },
        ],
        "generationConfig": {
          "thinkingConfig": {"thinkingBudget": -1},
        },
      };
      var response = await _restService.POST(model!.endpoint, payload);
      if (response.statusCode != 200) {
        _logService.addWarningLog(logKey, "Status code ${response.statusCode}");

        return AiResponse(message: '', success: false, responseEnded: true);
      }
      _logService.addSuccessLog(logKey, "Success ${modelType}");
      var body = jsonDecode(response.body);
      var aiResp = AiResponse(
        message: body['candidates'][0]['content']['parts'][0]['text'],
        success: true,
        responseEnded: true,
      );
      return aiResp;
    } catch (e) {
      _logService.addErrorLog(logKey, "Error ${e.toString()}");
      return AiResponse(message: '', success: false, responseEnded: true);
    }
  }

  Future<AiResponse> getResponse2(
    AiChatContent content, {
    Models modelType = Models.Flash,
  }) async {
    try {
      await setModels();
      var model = _models[modelType];
      var payload = content.toJson();
      _logService.addInfoLog(logKey, "Send Req ${modelType.toString()}");

      var response = await _restService.POST(model!.endpoint, payload);
      if (response.statusCode != 200) {
        _logService.addWarningLog(logKey, "Status code ${response.statusCode}");
        return AiResponse(message: '', success: false, responseEnded: true);
      }
      _logService.addSuccessLog(logKey, "Success ${modelType}");

      var body = jsonDecode(response.body);
      var aiResp = AiResponse(
        message: body['candidates'][0]['content']['parts'][0]['text'],
        success: true,
        responseEnded: true,
      );
      return aiResp;
    } catch (e) {
      _logService.addErrorLog(logKey, "Error ${e.toString()}");
      return AiResponse(message: '', success: false, responseEnded: true);
    }
  }

  Future<StreamController<AiResponse>?> streamGeminiResponse(
    AiChatContent chatContent,
  ) async {
    await setModels();
    final StreamController<AiResponse> controller =
        StreamController<AiResponse>();
    var test = jsonEncode(chatContent.toJson());
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?alt=sse',
    );
    _logService.addInfoLog(logKey, "Send Stream Req gemini-2.5-flash");

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['x-goog-api-key'] = API_KEY
      ..body = test;

    final response = await request.send();

    if (response.statusCode == 200) {
      // Handle streaming SSE
      response.stream
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen(
            (line) {
              // SSE lines start with "data: "
              if (line.startsWith("data: ")) {
                final data = line.substring(6).trim();
                if (data == '[DONE]') {
                  controller.close();
                } else {
                  final jsonData = jsonDecode(data);
                  final text =
                      jsonData['candidates']?[0]?['content']?['parts']?[0]?['text'];
                  if (text != null) {
                    controller.add(
                      AiResponse(
                        message: text,
                        success: true,
                        responseEnded: false,
                      ),
                    );
                  }
                }
              }
            },
            onDone: () {
              controller.close();
            },
          );
      return controller;
    } else {
      return null;
    }
  }

  removeJsonAnnotation(String data) {
    if (data.startsWith('```')) {
      data = data.substring(7, data.length - 3);
    }
    return data;
  }
}

class _AI_Provider {
  final modelName;
  final String apiKey;
  final String endpoint;
  _AI_Provider({
    required this.modelName,
    required this.apiKey,
    required this.endpoint,
  });
}
