// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../userGoal.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserGoalAdapter extends TypeAdapter<UserGoal> {
  @override
  final int typeId = 37;

  @override
  UserGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserGoal(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime?,
      isActive: fields[2] as bool,
      stepGoal: fields[3] as int,
      targetWeight: fields[4] as double,
      caloricChangeGoal: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserGoal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.isActive)
      ..writeByte(3)
      ..write(obj.stepGoal)
      ..writeByte(4)
      ..write(obj.targetWeight)
      ..writeByte(5)
      ..write(obj.caloricChangeGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
