// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advice.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdviceAdapter extends TypeAdapter<Advice> {
  @override
  final int typeId = 20;

  @override
  Advice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Advice(
      adviceDesc: fields[0] as String,
      status: fields[1] as AdviceStatus,
      conditions: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Advice obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.adviceDesc)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.conditions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdviceStatusAdapter extends TypeAdapter<AdviceStatus> {
  @override
  final int typeId = 21;

  @override
  AdviceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdviceStatus.worked;
      case 1:
        return AdviceStatus.onGoing;
      case 2:
        return AdviceStatus.notWorked;
      default:
        return AdviceStatus.worked;
    }
  }

  @override
  void write(BinaryWriter writer, AdviceStatus obj) {
    switch (obj) {
      case AdviceStatus.worked:
        writer.writeByte(0);
        break;
      case AdviceStatus.onGoing:
        writer.writeByte(1);
        break;
      case AdviceStatus.notWorked:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdviceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
