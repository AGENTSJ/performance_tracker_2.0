// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JourneyAdapter extends TypeAdapter<Journey> {
  @override
  final int typeId = 18;

  @override
  Journey read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Journey(
      startDate: fields[0] as DateTime,
      userTarget: fields[1] as UserGoals,
      caloriesChangeAchieved: fields[2] as double,
      stepsWalked: fields[3] as int,
      onProgress: fields[4] as bool,
      lastUpdated: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Journey obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.userTarget)
      ..writeByte(2)
      ..write(obj.caloriesChangeAchieved)
      ..writeByte(3)
      ..write(obj.stepsWalked)
      ..writeByte(4)
      ..write(obj.onProgress)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
