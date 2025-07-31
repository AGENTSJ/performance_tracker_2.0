import 'dart:async';
import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/rest.service.dart';
import 'package:http/http.dart' as http;
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';


enum Models { Pro, Flash }

class AiService {
  final _restService = locator<RestService>();
  late final Map<Models, _AI_Provider> _models;
  var API_KEY = 'AIzaSyD6G15zpLNW9OtnDKveFIG9vZM8jw1yO5E';

  AiService() {
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
    print("ai response fetch");
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
      return AiResponse(message: '', success: false,responseEnded: true);
    }
    try {
      var body = jsonDecode(response.body);
      var aiResp = AiResponse(
        message: body['candidates'][0]['content']['parts'][0]['text'],
        success: true,
        responseEnded: true
      );
      return aiResp;
    } catch (e) {
      return AiResponse(message: '', success: false,responseEnded: true);
    }
  }

  Future<StreamController<AiResponse>?> streamGeminiResponse(AiChatContent chatContent) async {
    print("ai response fetch");
    final StreamController<AiResponse> controller = StreamController<AiResponse>();
    var test = jsonEncode(toMap(chatContent));
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?alt=sse',
    );

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['x-goog-api-key'] = API_KEY
      ..body = test;

    final response = await request.send();

    if (response.statusCode == 200) {
      // Handle streaming SSE
      response.stream.transform(utf8.decoder).transform(LineSplitter()).listen((
        line,
      ) {
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
              controller.add(AiResponse(message: text, success: true, responseEnded: false));
            }
          }
        }
      });
      return controller;
    } else {
      return null;
    }
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
