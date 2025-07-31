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
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.generatedAt)
      ..writeByte(1)
      ..write(obj.entityLastUpdated)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.reportData);
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
