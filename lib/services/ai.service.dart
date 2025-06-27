import 'dart:convert';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/rest.service.dart';

class AiResponse
{
  final String message;
  final bool success;

  const AiResponse({required this.message , required this.success}); 
}
class AiService
{
  late final _AI_Provider _provider;
  final _restService = locator<RestService>();
  AiService() 
  {
    var API_KEY = 'AIzaSyD6G15zpLNW9OtnDKveFIG9vZM8jw1yO5E';
    var modelName = "gemini-2.0-flash";
    _provider = _AI_Provider(apiKey: API_KEY,modelName: modelName,endpoint:"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY");
  } 

  Future<AiResponse> getResponse(String promt , String? instructions) async 
  {
    dynamic payload = {
      "system_instruction": {
        "parts": [
          {
            "text": instructions ?? ""
          }
        ]
      },
      "contents":[
        {
          "parts":[
            {
              "text": promt
            }
          ]
        }
      ]
    };
    var response = await _restService.POST(_provider.endpoint, payload);
    if(response.statusCode!=200)
    {
      return AiResponse(message: '', success: false);
    }

    var body = jsonDecode(response.body);
    var aiResp = AiResponse(message: body['candidates'][0]['content']['parts'][0]['text'], success: true);
    return aiResp;
  }

}

class _AI_Provider
{
  final modelName;
  final String apiKey;
  final String endpoint;
  _AI_Provider({required this.modelName ,required this.apiKey,required this.endpoint});
}