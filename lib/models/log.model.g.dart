// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogModelAdapter extends TypeAdapter<LogModel> {
  @override
  final int typeId = 35;

  @override
  LogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogModel(
      entityId: fields[0] as String,
      message: fields[1] as String,
      timestamp: fields[2] as DateTime,
      level: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LogModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.entityId)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
