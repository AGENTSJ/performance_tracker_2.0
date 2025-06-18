import 'dart:convert';

import 'package:http/http.dart' ;

class RestService
{
  final _headers = {'Content-Type': 'application/json'};
  
  GET(String url) 
  {
    final response = get(Uri.parse(url),headers:_headers,); 
    return response;
  }
  
  Future<Response> POST(url,payload) 
  {
    final response = post(
      Uri.parse(url),
      body: jsonEncode(payload),
      headers: _headers
    );
    return response;
  }
}