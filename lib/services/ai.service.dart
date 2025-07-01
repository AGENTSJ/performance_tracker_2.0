import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/rest.service.dart';

class AiResponse {
  final String message;
  final bool success;

  const AiResponse({required this.message, required this.success});
}

enum Models { Pro, Flash }

class AiService {
  final _restService = locator<RestService>();
  late final Map<Models, _AI_Provider> _models;

  AiService() {
    var API_KEY = 'AIzaSyD6G15zpLNW9OtnDKveFIG9vZM8jw1yO5E';
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
    // _provider = ;
  }

  Future<AiResponse> getResponse(
    String promt,
    String? instructions, {
    Models modelType = Models.Flash,
  }) async {
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
      return AiResponse(message: '', success: false);
    }
    try {
      var body = jsonDecode(response.body);
      var aiResp = AiResponse(
        message: body['candidates'][0]['content']['parts'][0]['text'],
        success: true,
      );
      return aiResp;
    } catch (e) {
      return AiResponse(message: '', success: false);
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
