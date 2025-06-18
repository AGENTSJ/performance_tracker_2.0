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
      dayTime: fields[4] as DateTime,
    )
      ..breakFast = fields[0] as Meal
      ..lunch = fields[1] as Meal
      ..dinner = fields[2] as Meal
      ..meals = (fields[3] as List?)?.cast<Meal>();
  }

  @override
  void write(BinaryWriter writer, Day obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.breakFast)
      ..writeByte(1)
      ..write(obj.lunch)
      ..writeByte(2)
      ..write(obj.dinner)
      ..writeByte(3)
      ..write(obj.meals)
      ..writeByte(4)
      ..write(obj.dayTime);
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
