import 'dart:convert';

import 'package:http/http.dart' ;

class RestService
{
  var headers = {'Content-Type': 'application/json'};
  
  GET(String url) 
  {
    final response = get(Uri.parse(url),headers: {'Content-Type': 'application/json'},); 
    return response;
  }
  
  Future<Response> POST(url,payload) 
  {
    final response = post(
      Uri.parse(url),
      body: jsonEncode(payload),
      headers: headers
    );
    return response;
  }
}