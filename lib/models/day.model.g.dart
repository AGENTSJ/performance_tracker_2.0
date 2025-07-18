// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayAdapter extends TypeAdapter<Day> {
  @override
  final int typeId = 5;

  @override
  Day read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Day(
      dayTime: fields[7] as DateTime,
    )
      ..breakFast = fields[0] as Meal
      ..lunch = fields[1] as Meal
      ..morningSnacks = fields[2] as Meal
      ..dinner = fields[3] as Meal
      ..eveningSnacks = fields[5] as Meal
      ..meals = (fields[6] as List?)?.cast<Meal>()
      ..comments = fields[8] as DayComments?
      ..goalForToday = fields[9] as UserGoals?
      ..routineId = fields[10] as int?
      ..activity = fields[11] as Activity?;
  }

  @override
  void write(BinaryWriter writer, Day obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.breakFast)
      ..writeByte(1)
      ..write(obj.lunch)
      ..writeByte(2)
      ..write(obj.morningSnacks)
      ..writeByte(3)
      ..write(obj.dinner)
      ..writeByte(5)
      ..write(obj.eveningSnacks)
      ..writeByte(6)
      ..write(obj.meals)
      ..writeByte(7)
      ..write(obj.dayTime)
      ..writeByte(8)
      ..write(obj.comments)
      ..writeByte(9)
      ..write(obj.goalForToday)
      ..writeByte(10)
      ..write(obj.routineId)
      ..writeByte(11)
      ..write(obj.activity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealAdapter extends TypeAdapter<Meal> {
  @override
  final int typeId = 6;

  @override
  Meal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meal(
      mealName: fields[0] as String,
      foods: (fields[1] as List).cast<Food>(),
      calories: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.mealName)
      ..writeByte(1)
      ..write(obj.foods)
      ..writeByte(2)
      ..write(obj.calories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayCommentsAdapter extends TypeAdapter<DayComments> {
  @override
  final int typeId = 7;

  @override
  DayComments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayComments()
      ..macroNutrientsComments = fields[0] as GeneratedComment?
      ..microNutrientsComments = fields[1] as GeneratedComment?
      ..overallDietComments = fields[2] as GeneratedComment?;
  }

  @override
  void write(BinaryWriter writer, DayComments obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.macroNutrientsComments)
      ..writeByte(1)
      ..write(obj.microNutrientsComments)
      ..writeByte(2)
      ..write(obj.overallDietComments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayCommentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeneratedCommentAdapter extends TypeAdapter<GeneratedComment> {
  @override
  final int typeId = 8;

  @override
  GeneratedComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeneratedComment(
      comment: fields[0] as String,
      timeOfGeneration: fields[1] as DateTime,
      macrosAtGenTime: fields[2] as MacroNutrients,
    );
  }

  @override
  void write(BinaryWriter writer, GeneratedComment obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.comment)
      ..writeByte(1)
      ..write(obj.timeOfGeneration)
      ..writeByte(2)
      ..write(obj.macrosAtGenTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratedCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
