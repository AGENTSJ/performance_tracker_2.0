// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AiResponse.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiResponseAdapter extends TypeAdapter<AiResponse> {
  @override
  final int typeId = 25;

  @override
  AiResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiResponse(
      message: fields[0] as String,
      success: fields[1] as bool,
      responseEnded: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AiResponse obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.success)
      ..writeByte(2)
      ..write(obj.responseEnded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatPartAdapter extends TypeAdapter<ChatPart> {
  @override
  final int typeId = 27;

  @override
  ChatPart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatPart(
      text: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatPart obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatPartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AiChatSegmentAdapter extends TypeAdapter<AiChatSegment> {
  @override
  final int typeId = 28;

  @override
  AiChatSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiChatSegment(
      role: fields[0] as ChatRoles?,
      parts: (fields[1] as List).cast<ChatPart>(),
    );
  }

  @override
  void write(BinaryWriter writer, AiChatSegment obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.role)
      ..writeByte(1)
      ..write(obj.parts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AiChatContentAdapter extends TypeAdapter<AiChatContent> {
  @override
  final int typeId = 29;

  @override
  AiChatContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiChatContent(
      system_instruction: fields[0] as AiChatSegment?,
      contents: (fields[1] as List).cast<AiChatSegment>(),
    );
  }

  @override
  void write(BinaryWriter writer, AiChatContent obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.system_instruction)
      ..writeByte(1)
      ..write(obj.contents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatRolesAdapter extends TypeAdapter<ChatRoles> {
  @override
  final int typeId = 26;

  @override
  ChatRoles read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatRoles.model;
      case 1:
        return ChatRoles.user;
      default:
        return ChatRoles.model;
    }
  }

  @override
  void write(BinaryWriter writer, ChatRoles obj) {
    switch (obj) {
      case ChatRoles.model:
        writer.writeByte(0);
        break;
      case ChatRoles.user:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRolesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
