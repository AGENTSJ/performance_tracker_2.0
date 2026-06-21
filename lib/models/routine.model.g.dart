// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineAdapter extends TypeAdapter<Routine> {
  @override
  final int typeId = 13;

  @override
  Routine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Routine(
      name: fields[0] as String,
      workoutsIds: (fields[1] as List).cast<int>(),
      createdAt: fields[2] as DateTime,
      isCustom: fields[3] as bool,
      desc: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Routine obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.workoutsIds)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.isCustom)
      ..writeByte(4)
      ..write(obj.desc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 14;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      name: fields[0] as String,
      sets: (fields[1] as List).cast<WorkSet>(),
      enabled: fields[2] as bool,
      desc: fields[3] as String,
      volumes: (fields[4] as List).cast<WorkoutVolume>(),
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.enabled)
      ..writeByte(3)
      ..write(obj.desc)
      ..writeByte(4)
      ..write(obj.volumes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkSetAdapter extends TypeAdapter<WorkSet> {
  @override
  final int typeId = 15;

  @override
  WorkSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkSet(
      value: fields[0] as double,
      history: (fields[1] as List).cast<TrackEntry>(),
      pr: fields[2] as int,
      enabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkSet obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.history)
      ..writeByte(2)
      ..write(obj.pr)
      ..writeByte(3)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrackEntryAdapter extends TypeAdapter<TrackEntry> {
  @override
  final int typeId = 16;

  @override
  TrackEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackEntry(
      entryDate: fields[0] as DateTime,
      value: fields[1] as int,
      fatigueContext: fields[2] == null ? 0.0 : fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TrackEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.entryDate)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.fatigueContext);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutVolumeAdapter extends TypeAdapter<WorkoutVolume> {
  @override
  final int typeId = 19;

  @override
  WorkoutVolume read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutVolume(
      muscleName: fields[0] as String,
      volume: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutVolume obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.muscleName)
      ..writeByte(1)
      ..write(obj.volume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutVolumeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
