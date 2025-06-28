// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final int typeId = 0;

  @override
  Food read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food(
      name: fields[0] as String,
      macros: fields[1] as MacroNutrients,
      micros: fields[2] as MicroNutrients,
      quantity: fields[3] as MeasuredUnit,
      imageUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.macros)
      ..writeByte(2)
      ..write(obj.micros)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MacroNutrientsAdapter extends TypeAdapter<MacroNutrients> {
  @override
  final int typeId = 1;

  @override
  MacroNutrients read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MacroNutrients(
      fields[0] as double,
      fields[2] as double,
      fields[1] as double,
      fields[3] as double,
      fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MacroNutrients obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.protein)
      ..writeByte(1)
      ..write(obj.fat)
      ..writeByte(2)
      ..write(obj.carbohydrate)
      ..writeByte(3)
      ..write(obj.fiber)
      ..writeByte(4)
      ..write(obj.calories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacroNutrientsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MicroNutrientsAdapter extends TypeAdapter<MicroNutrients> {
  @override
  final int typeId = 2;

  @override
  MicroNutrients read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MicroNutrients(
      vitaminA: fields[0] as MeasuredUnit?,
      vitaminC: fields[1] as MeasuredUnit?,
      vitaminD: fields[2] as MeasuredUnit?,
      vitaminE: fields[3] as MeasuredUnit?,
      vitaminK: fields[4] as MeasuredUnit?,
      thiamin: fields[5] as MeasuredUnit?,
      riboflavin: fields[6] as MeasuredUnit?,
      niacin: fields[7] as MeasuredUnit?,
      vitaminB6: fields[8] as MeasuredUnit?,
      folate: fields[9] as MeasuredUnit?,
      vitaminB12: fields[10] as MeasuredUnit?,
      pantothenicAcid: fields[11] as MeasuredUnit?,
      biotin: fields[12] as MeasuredUnit?,
      calcium: fields[13] as MeasuredUnit?,
      iron: fields[14] as MeasuredUnit?,
      magnesium: fields[15] as MeasuredUnit?,
      phosphorus: fields[16] as MeasuredUnit?,
      potassium: fields[17] as MeasuredUnit?,
      sodium: fields[18] as MeasuredUnit?,
      zinc: fields[19] as MeasuredUnit?,
      copper: fields[20] as MeasuredUnit?,
      manganese: fields[21] as MeasuredUnit?,
      selenium: fields[22] as MeasuredUnit?,
      iodine: fields[23] as MeasuredUnit?,
      chromium: fields[24] as MeasuredUnit?,
      molybdenum: fields[25] as MeasuredUnit?,
      fluoride: fields[26] as MeasuredUnit?,
      chloride: fields[27] as MeasuredUnit?,
    );
  }

  @override
  void write(BinaryWriter writer, MicroNutrients obj) {
    writer
      ..writeByte(28)
      ..writeByte(0)
      ..write(obj.vitaminA)
      ..writeByte(1)
      ..write(obj.vitaminC)
      ..writeByte(2)
      ..write(obj.vitaminD)
      ..writeByte(3)
      ..write(obj.vitaminE)
      ..writeByte(4)
      ..write(obj.vitaminK)
      ..writeByte(5)
      ..write(obj.thiamin)
      ..writeByte(6)
      ..write(obj.riboflavin)
      ..writeByte(7)
      ..write(obj.niacin)
      ..writeByte(8)
      ..write(obj.vitaminB6)
      ..writeByte(9)
      ..write(obj.folate)
      ..writeByte(10)
      ..write(obj.vitaminB12)
      ..writeByte(11)
      ..write(obj.pantothenicAcid)
      ..writeByte(12)
      ..write(obj.biotin)
      ..writeByte(13)
      ..write(obj.calcium)
      ..writeByte(14)
      ..write(obj.iron)
      ..writeByte(15)
      ..write(obj.magnesium)
      ..writeByte(16)
      ..write(obj.phosphorus)
      ..writeByte(17)
      ..write(obj.potassium)
      ..writeByte(18)
      ..write(obj.sodium)
      ..writeByte(19)
      ..write(obj.zinc)
      ..writeByte(20)
      ..write(obj.copper)
      ..writeByte(21)
      ..write(obj.manganese)
      ..writeByte(22)
      ..write(obj.selenium)
      ..writeByte(23)
      ..write(obj.iodine)
      ..writeByte(24)
      ..write(obj.chromium)
      ..writeByte(25)
      ..write(obj.molybdenum)
      ..writeByte(26)
      ..write(obj.fluoride)
      ..writeByte(27)
      ..write(obj.chloride);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicroNutrientsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeasuredUnitAdapter extends TypeAdapter<MeasuredUnit> {
  @override
  final int typeId = 3;

  @override
  MeasuredUnit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeasuredUnit(
      value: fields[0] as double,
      unit: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MeasuredUnit obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasuredUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
