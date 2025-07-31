// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 30;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Report(
      generatedAt: fields[0] as DateTime,
      entityLastUpdated: fields[1] as DateTime,
      entityId: fields[2] as String,
      reportData: fields[3] as String,
      entityName: fields[4] as String,
      type: fields[5] as EntityType,
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.generatedAt)
      ..writeByte(1)
      ..write(obj.entityLastUpdated)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.reportData)
      ..writeByte(4)
      ..write(obj.entityName)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EntityTypeAdapter extends TypeAdapter<EntityType> {
  @override
  final int typeId = 31;

  @override
  EntityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EntityType.workout;
      case 1:
        return EntityType.routine;
      case 2:
        return EntityType.nutrition;
      case 3:
        return EntityType.activity;
      case 4:
        return EntityType.other;
      default:
        return EntityType.workout;
    }
  }

  @override
  void write(BinaryWriter writer, EntityType obj) {
    switch (obj) {
      case EntityType.workout:
        writer.writeByte(0);
        break;
      case EntityType.routine:
        writer.writeByte(1);
        break;
      case EntityType.nutrition:
        writer.writeByte(2);
        break;
      case EntityType.activity:
        writer.writeByte(3);
        break;
      case EntityType.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
