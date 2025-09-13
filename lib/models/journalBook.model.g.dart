// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journalBook.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalBookAdapter extends TypeAdapter<JournalBook> {
  @override
  final int typeId = 32;

  @override
  JournalBook read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalBook(
      (fields[0] as List).cast<Journal>(),
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JournalBook obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.journals)
      ..writeByte(1)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalBookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JournalAdapter extends TypeAdapter<Journal> {
  @override
  final int typeId = 33;

  @override
  Journal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Journal(
      fields[0] as DateTime,
      fields[1] as String,
      (fields[2] as List).cast<String>(),
      fields[3] as String,
      fields[4] as String?,
      fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Journal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dateOfJournal)
      ..writeByte(1)
      ..write(obj.journalData)
      ..writeByte(2)
      ..write(obj.imagePaths)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.backgroundImageUrl)
      ..writeByte(5)
      ..write(obj.opacity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
