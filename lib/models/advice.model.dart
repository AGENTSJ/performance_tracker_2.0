import 'package:hive_flutter/adapters.dart';
part 'advice.model.g.dart';
@HiveType(typeId: 20)
class Advice extends HiveObject
{
  @HiveField(0)
  String adviceDesc;
  @HiveField(1)
  AdviceStatus status;
  @HiveField(2)
  String conditions;
  Advice({required this.adviceDesc,required this.status, required this.conditions});
}
@HiveType(typeId: 21)
enum AdviceStatus {
  @HiveField(0)
  worked,
  @HiveField(1)
  onGoing,
  @HiveField(2)
  notWorked,
}