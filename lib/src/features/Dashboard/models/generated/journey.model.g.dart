// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../journey.model.dart';

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
      logs: (fields[7] as List).cast<JourneyLog>(),
      status: fields[8] as JourneyStatus,
      goalId: fields[10] as int?,
    )
      ..lastUpdated = fields[4] as DateTime?
      ..lastCaloriesValue = fields[5] as double?
      ..lastStepValue = fields[6] as int?
      ..reasonToStop = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, Journey obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.userAtStart)
      ..writeByte(2)
      ..write(obj.caloriesChangeAchieved)
      ..writeByte(3)
      ..write(obj.stepsWalked)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.lastCaloriesValue)
      ..writeByte(6)
      ..write(obj.lastStepValue)
      ..writeByte(7)
      ..write(obj.logs)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.reasonToStop)
      ..writeByte(10)
      ..write(obj.goalId);
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
      dayId: fields[0] as int?,
      dateKey: fields[2] as String?,
      userAtDay: fields[1] as User,
    );
  }

  @override
  void write(BinaryWriter writer, JourneyLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dayId)
      ..writeByte(1)
      ..write(obj.userAtDay)
      ..writeByte(2)
      ..write(obj.dateKey);
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

class JourneyStatusAdapter extends TypeAdapter<JourneyStatus> {
  @override
  final int typeId = 23;

  @override
  JourneyStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return JourneyStatus.onProgress;
      case 1:
        return JourneyStatus.failed;
      case 2:
        return JourneyStatus.completed;
      default:
        return JourneyStatus.onProgress;
    }
  }

  @override
  void write(BinaryWriter writer, JourneyStatus obj) {
    switch (obj) {
      case JourneyStatus.onProgress:
        writer.writeByte(0);
        break;
      case JourneyStatus.failed:
        writer.writeByte(1);
        break;
      case JourneyStatus.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
