import 'package:hive/hive.dart';

part 'AiResponse.model.g.dart';

@HiveType(typeId: 25)
class AiResponse extends HiveObject {
  @HiveField(0)
  final String message;

  @HiveField(1)
  final bool success;

  @HiveField(2)
  final bool responseEnded;

  AiResponse({
    required this.message,
    required this.success,
    required this.responseEnded,
  });
}

@HiveType(typeId: 26)
enum ChatRoles {
  @HiveField(0)
  model('model'),
  @HiveField(1)
  user('user');

  final String value;
  const ChatRoles(this.value);
}

@HiveType(typeId: 27)
class ChatPart extends HiveObject {
  @HiveField(0)
  String text;

  ChatPart({required this.text});
}

@HiveType(typeId: 28)
class AiChatSegment extends HiveObject {
  @HiveField(0)
  ChatRoles? role;

  @HiveField(1)
  List<ChatPart> parts;

  AiChatSegment({required this.role, required this.parts});
}

@HiveType(typeId: 29)
class AiChatContent extends HiveObject {
  @HiveField(0)
  AiChatSegment? system_instruction; // role is null for system inst
  @HiveField(1)
  List<AiChatSegment> contents;
  AiChatContent({required this.system_instruction, required this.contents});
}

Map<String, dynamic> toMap(AiChatContent object) {
  return {
    'system_instruction': object.system_instruction == null
        ? null
        : {
            'role': object.system_instruction!.role?.value,
            'parts': object.system_instruction!.parts
                .map((part) => {'text': part.text})
                .toList(),
          },
    'contents': object.contents
        .map(
          (segment) => {
            'role': segment.role?.value,
            'parts': segment.parts.map((part) => {'text': part.text}).toList(),
          },
        )
        .toList(),
  };
}
