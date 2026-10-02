// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../fatigue.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FatigueDayAdapter extends TypeAdapter<FatigueDay> {
  @override
  final int typeId = 36;

  @override
  FatigueDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FatigueDay(
      dateKey: fields[0] as String,
      muscleFatigue: (fields[1] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, FatigueDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.muscleFatigue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FatigueDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
