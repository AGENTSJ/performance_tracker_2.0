import 'dart:async';
import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/key.service.dart';
import 'package:performance_tracker/services/log.service.dart';
import 'package:performance_tracker/services/rest.service.dart';
import 'package:http/http.dart' as http;
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Models { Pro, Flash }

/// Lightweight cancellation handle for an in-flight streamed request.
/// Calling [cancel] aborts the underlying HTTP connection.
class CancelToken {
  bool isCancelled = false;
  void Function()? onCancel;
  void cancel() {
    if (isCancelled) return;
    isCancelled = true;
    onCancel?.call();
  }
}

/// A Gemini model as returned by the list-models endpoint.
class GeminiModel {
  final String name; // e.g. "models/gemini-2.0-flash"
  final String displayName; // e.g. "Gemini 2.0 Flash"
  GeminiModel({required this.name, required this.displayName});

  factory GeminiModel.fromJson(Map<String, dynamic> json) => GeminiModel(
    name: json['name'] as String,
    displayName: (json['displayName'] ?? json['name']) as String,
  );
}

class AiService {
  final _restService = locator<RestService>();
  final _logService = locator<LogService>();
  late Map<Models, _AI_Provider> _models;
  final keyService = locator<KeyService>();
  String API_KEY = '';
  final logKey = 'AI';

  // App-wide selected Gemini model (persisted). Used by the AI food creator
  // and the coach chat.
  static const String defaultModel = 'models/gemini-2.0-flash';
  static const String _keySelectedModel = 'selectedAiModel';
  // Separate model used by the coach when *acting* (applying advice). Kept
  // independent of the chat/food-creator model so it can be tuned on its own.
  static const String _keySelectedActModel = 'selectedActAiModel';

  AiService() {
    setModels();
  }

  /// The currently selected Gemini model name, or [defaultModel] if none set.
  Future<String> getSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedModel) ?? defaultModel;
  }

  Future<void> setSelectedModel(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedModel, modelName);
  }

  /// The model used for coach "act" (advice application), or [defaultModel].
  Future<String> getSelectedActModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedActModel) ?? defaultModel;
  }

  Future<void> setSelectedActModel(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedActModel, modelName);
  }

  /// Fetches the Gemini models available for the configured API key, keeping
  /// only those that support `generateContent`.
  Future<List<GeminiModel>> fetchAvailableModels() async {
    try {
      await setModels();
      final url =
          "https://generativelanguage.googleapis.com/v1beta/models?key=$API_KEY";
      final response = await _restService.GET(url);
      if (response.statusCode != 200) {
        _logService.addWarningLog(
          logKey,
          "List models status ${response.statusCode}",
        );
        return [];
      }
      final body = jsonDecode(response.body);
      final models = (body['models'] as List<dynamic>? ?? [])
          .where(
            (m) => ((m['supportedGenerationMethods'] as List<dynamic>?) ?? [])
                .contains('generateContent'),
          )
          .map((m) => GeminiModel.fromJson(m as Map<String, dynamic>))
          .toList();
      return models;
    } catch (e) {
      _logService.addErrorLog(logKey, "List models error ${e.toString()}");
      return [];
    }
  }
  setModels() async {
    API_KEY = await keyService.getAiApiKey() ?? '';
    var modelName = "gemini-2.0-flash";
    _models = {
      Models.Pro: _AI_Provider(
        apiKey: API_KEY,
        modelName: modelName,
        endpoint:
            "https://generativelanguage.googleapis.com/v1beta/models/gemma-4-26b-a4b-it:generateContent?key=${API_KEY}",
      ),
      Models.Flash: _AI_Provider(
        apiKey: API_KEY,
        modelName: modelName,
        endpoint:
            "https://generativelanguage.googleapis.com/v1beta/models/gemma-4-26b-a4b-it:generateContent?key=${API_KEY}",
      ),
    };
  }

  Future<AiResponse> getResponse(
    String promt,
    String? instructions, {
    Models modelType = Models.Flash,
    String? modelName,
  }) async {
    try {
      await setModels();
      _logService.addInfoLog(
        logKey,
        "Send Req ${modelName ?? modelType.toString()}",
      );
      // An explicit modelName overrides the legacy Pro/Flash mapping.
      final endpoint = modelName != null
          ? "https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$API_KEY"
          : _models[modelType]!.endpoint;
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
      };
      var response = await _restService.POST(endpoint, payload);
      if (response.statusCode != 200) {
        _logService.addWarningLog(logKey, "Status code ${response.statusCode}");

        return AiResponse(message: '', success: false, responseEnded: true);
      }
      _logService.addSuccessLog(logKey, "Success ${modelType}");
      var body = jsonDecode(response.body);
      final parts = body['candidates'][0]['content']['parts'];
      final text = parts
          .where((p) => p['thought'] != true)
          .map((p) => p['text'] ?? '')
          .join();
      var aiResp = AiResponse(
        message: text,
        success: true,
        responseEnded: true,
      );
      return aiResp;
    } catch (e) {
      _logService.addErrorLog(logKey, "Error ${e.toString()}");
      return AiResponse(message: '', success: false, responseEnded: true);
    }
  }

  /// Streams a `generateContent` response over SSE so callers can surface live
  /// progress. [onProgress] is invoked on every chunk with the cumulative
  /// (thoughts, answer) text so far. The returned [AiResponse] holds the full
  /// concatenated answer text, ready to be parsed like [getResponse]. Falls
  /// back to the non-streaming [getResponse] if streaming can't be started.
  ///
  /// Pass a [cancelToken] to abort: cancelling cancels the stream subscription
  /// and closes the HTTP client, tearing down the connection. The result then
  /// has `success == false`.
  Future<AiResponse> getResponseStream(
    String promt,
    String? instructions, {
    Models modelType = Models.Flash,
    String? modelName,
    void Function(String thoughts, String answer)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      return AiResponse(message: '', success: false, responseEnded: true);
    }
    final client = http.Client();
    try {
      await setModels();
      var modelPath = modelName ?? _models[modelType]!.modelName;
      if (!modelPath.startsWith('models/')) modelPath = 'models/$modelPath';
      _logService.addInfoLog(logKey, "Send Stream Req $modelPath");

      final uri = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/$modelPath:streamGenerateContent?alt=sse&key=$API_KEY",
      );
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
      };

      final request = http.Request('POST', uri)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(payload);
      final response = await client.send(request);

      if (response.statusCode != 200) {
        _logService.addWarningLog(
          logKey,
          "Stream status ${response.statusCode}, falling back",
        );
        client.close();
        return getResponse(
          promt,
          instructions,
          modelType: modelType,
          modelName: modelName,
        );
      }

      final answerBuffer = StringBuffer();
      final thoughtBuffer = StringBuffer();
      final completer = Completer<void>();

      final subscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!line.startsWith('data:')) return;
              final data = line.substring(5).trim();
              if (data.isEmpty || data == '[DONE]') return;
              try {
                final json = jsonDecode(data);
                final parts =
                    json['candidates']?[0]?['content']?['parts']
                        as List<dynamic>?;
                if (parts == null) return;
                for (final p in parts) {
                  final text = (p['text'] ?? '') as String;
                  if (text.isEmpty) continue;
                  if (p['thought'] == true) {
                    thoughtBuffer.write(text);
                  } else {
                    answerBuffer.write(text);
                  }
                }
                onProgress?.call(
                  thoughtBuffer.toString(),
                  answerBuffer.toString(),
                );
              } catch (_) {
                // Ignore keep-alive / partial non-JSON lines.
              }
            },
            onError: (e) {
              if (!completer.isCompleted) completer.completeError(e);
            },
            onDone: () {
              if (!completer.isCompleted) completer.complete();
            },
            cancelOnError: true,
          );

      // Wire the cancel handle: tear down the subscription + connection.
      cancelToken?.onCancel = () {
        subscription.cancel();
        client.close();
        if (!completer.isCompleted) completer.complete();
      };

      await completer.future;

      if (cancelToken?.isCancelled == true) {
        _logService.addInfoLog(logKey, "Stream aborted $modelPath");
        return AiResponse(
          message: answerBuffer.toString(),
          success: false,
          responseEnded: true,
        );
      }

      _logService.addSuccessLog(logKey, "Stream success $modelPath");
      return AiResponse(
        message: answerBuffer.toString(),
        success: true,
        responseEnded: true,
      );
    } catch (e) {
      _logService.addErrorLog(logKey, "Stream error ${e.toString()}");
      if (cancelToken?.isCancelled == true) {
        return AiResponse(message: '', success: false, responseEnded: true);
      }
      return getResponse(
        promt,
        instructions,
        modelType: modelType,
        modelName: modelName,
      );
    } finally {
      cancelToken?.onCancel = null;
      client.close();
    }
  }

  /// Streams a `generateContent` response over SSE for a full conversation
  /// ([AiChatContent], including system instruction + history), so callers can
  /// surface live progress. [onProgress] is invoked on every chunk with the
  /// cumulative (thoughts, answer) text so far. The returned [AiResponse] holds
  /// the full concatenated answer. Falls back to the non-streaming
  /// [getResponse2] if streaming can't be started.
  ///
  /// Pass a [cancelToken] to abort: cancelling cancels the stream subscription
  /// and closes the HTTP client. The result then has `success == false`.
  Future<AiResponse> getResponseStream2(
    AiChatContent content, {
    Models modelType = Models.Flash,
    String? modelName,
    void Function(String thoughts, String answer)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      return AiResponse(message: '', success: false, responseEnded: true);
    }
    final client = http.Client();
    try {
      await setModels();
      var modelPath = modelName ?? _models[modelType]!.modelName;
      if (!modelPath.startsWith('models/')) modelPath = 'models/$modelPath';
      _logService.addInfoLog(logKey, "Send Stream Req $modelPath");

      final uri = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/$modelPath:streamGenerateContent?alt=sse&key=$API_KEY",
      );

      final request = http.Request('POST', uri)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(content.toJson());
      final response = await client.send(request);

      if (response.statusCode != 200) {
        _logService.addWarningLog(
          logKey,
          "Stream status ${response.statusCode}, falling back",
        );
        client.close();
        return getResponse2(content, modelType: modelType);
      }

      final answerBuffer = StringBuffer();
      final thoughtBuffer = StringBuffer();
      final completer = Completer<void>();

      final subscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!line.startsWith('data:')) return;
              final data = line.substring(5).trim();
              if (data.isEmpty || data == '[DONE]') return;
              try {
                final json = jsonDecode(data);
                final parts =
                    json['candidates']?[0]?['content']?['parts']
                        as List<dynamic>?;
                if (parts == null) return;
                for (final p in parts) {
                  final text = (p['text'] ?? '') as String;
                  if (text.isEmpty) continue;
                  if (p['thought'] == true) {
                    thoughtBuffer.write(text);
                  } else {
                    answerBuffer.write(text);
                  }
                }
                onProgress?.call(
                  thoughtBuffer.toString(),
                  answerBuffer.toString(),
                );
              } catch (_) {
                // Ignore keep-alive / partial non-JSON lines.
              }
            },
            onError: (e) {
              if (!completer.isCompleted) completer.completeError(e);
            },
            onDone: () {
              if (!completer.isCompleted) completer.complete();
            },
            cancelOnError: true,
          );

      cancelToken?.onCancel = () {
        subscription.cancel();
        client.close();
        if (!completer.isCompleted) completer.complete();
      };

      await completer.future;

      if (cancelToken?.isCancelled == true) {
        _logService.addInfoLog(logKey, "Stream aborted $modelPath");
        return AiResponse(
          message: answerBuffer.toString(),
          success: false,
          responseEnded: true,
        );
      }

      _logService.addSuccessLog(logKey, "Stream success $modelPath");
      return AiResponse(
        message: answerBuffer.toString(),
        success: true,
        responseEnded: true,
      );
    } catch (e) {
      _logService.addErrorLog(logKey, "Stream error ${e.toString()}");
      if (cancelToken?.isCancelled == true) {
        return AiResponse(message: '', success: false, responseEnded: true);
      }
      return getResponse2(content, modelType: modelType);
    } finally {
      cancelToken?.onCancel = null;
      client.close();
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
      final parts = body['candidates'][0]['content']['parts'];
      final text = parts
          .where((p) => p['thought'] != true)
          .map((p) => p['text'] ?? '')
          .join();
      var aiResp = AiResponse(
        message: text,
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
      'https://generativelanguage.googleapis.com/v1beta/models/gemma-4-26b-a4b-it:generateContent?key=AIzaSyCYPombOhSAqcDQMDm_LfPbu8YYrjHcYkU',
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
