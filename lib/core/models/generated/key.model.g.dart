// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../key.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecretAppKeyAdapter extends TypeAdapter<SecretAppKey> {
  @override
  final int typeId = 34;

  @override
  SecretAppKey read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecretAppKey(
      keyName: fields[0] as String,
      keyVal: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SecretAppKey obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.keyName)
      ..writeByte(1)
      ..write(obj.keyVal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretAppKeyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
