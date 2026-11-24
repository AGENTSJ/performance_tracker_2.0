import 'dart:async';

import 'package:performance_tracker/src/features/Workout/models/advice.model.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';

class ChatDTO {
  String data;
  List<Advice> advices;
  ChatDTO({
    required this.data,
    required this.advices
  });
}
class ChatStreamDTO extends ChatDTO{
  StreamController<AiResponse> stream;
  StreamController<String>? eventStream;
  ChatStreamDTO({
    required super.data,
    required super.advices,
    required this.stream,
    required this.eventStream,
  });
}