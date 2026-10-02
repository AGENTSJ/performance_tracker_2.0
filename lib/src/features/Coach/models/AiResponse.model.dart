import 'package:hive/hive.dart';

part 'generated/AiResponse.model.g.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'system_instruction': system_instruction == null
          ? null
          : {
              'role': system_instruction!.role?.value,
              'parts': system_instruction!.parts
                  .map((part) => {'text': part.text})
                  .toList(),
            },
      'contents': contents
          .map(
            (segment) => {
              'role': segment.role?.value,
              'parts': segment.parts
                  .map((part) => {'text': part.text})
                  .toList(),
            },
          )
          .toList(),
    };
  }

  factory AiChatContent.fromJson(Map<String, dynamic> map) {
    ChatRoles? parseRole(String? value) {
      return ChatRoles.values.firstWhere(
        (e) => e.value == value,
        orElse: () => ChatRoles.model,
      );
    }

    AiChatSegment? systemInstruction;
    if (map['system_instruction'] != null) {
      final systemMap = map['system_instruction'];
      systemInstruction = AiChatSegment(
        role: parseRole(systemMap['role']),
        parts: (systemMap['parts'] as List)
            .map((e) => ChatPart(text: e['text']))
            .toList(),
      );
    }

    final contents = (map['contents'] as List)
        .map(
          (segment) => AiChatSegment(
            role: parseRole(segment['role']),
            parts: (segment['parts'] as List)
                .map((e) => ChatPart(text: e['text']))
                .toList(),
          ),
        )
        .toList();

    return AiChatContent(
      system_instruction: systemInstruction,
      contents: contents,
    );
  }
}
