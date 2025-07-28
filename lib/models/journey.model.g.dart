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
      userAtStart: fields[1] as User,
      caloriesChangeAchieved: fields[2] as double,
      stepsWalked: fields[3] as int,
      onProgress: fields[4] as bool,
      logs: (fields[8] as List).cast<JourneyLog>(),
    )
      ..lastUpdated = fields[5] as DateTime?
      ..lastCaloriesValue = fields[6] as double?
      ..lastStepValue = fields[7] as int?;
  }

  @override
  void write(BinaryWriter writer, Journey obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.userAtStart)
      ..writeByte(2)
      ..write(obj.caloriesChangeAchieved)
      ..writeByte(3)
      ..write(obj.stepsWalked)
      ..writeByte(4)
      ..write(obj.onProgress)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.lastCaloriesValue)
      ..writeByte(7)
      ..write(obj.lastStepValue)
      ..writeByte(8)
      ..write(obj.logs);
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

class JourneyLogAdapter extends TypeAdapter<JourneyLog> {
  @override
  final int typeId = 22;

  @override
  JourneyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JourneyLog(
      dayId: fields[0] as int,
      userAtDay: fields[1] as User,
    );
  }

  @override
  void write(BinaryWriter writer, JourneyLog obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dayId)
      ..writeByte(1)
      ..write(obj.userAtDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
