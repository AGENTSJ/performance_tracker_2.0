// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../fatigue.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FatigueEntryAdapter extends TypeAdapter<FatigueEntry> {
  @override
  final int typeId = 38;

  @override
  FatigueEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FatigueEntry(
      trackEntryId: fields[0] as String,
      muscleFatigue: (fields[1] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, FatigueEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.trackEntryId)
      ..writeByte(1)
      ..write(obj.muscleFatigue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FatigueEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
