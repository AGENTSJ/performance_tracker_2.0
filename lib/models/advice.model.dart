import 'package:hive_flutter/adapters.dart';
part 'advice.model.g.dart';
@HiveType(typeId: 20)
class Advice extends HiveObject
{
  @HiveField(0)
  String adviceDesc;
  @HiveField(1)
  String conditions;
  
  Advice({required this.adviceDesc, required this.conditions,});
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
@HiveType(typeId: 24)
class AdviceSet
{
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<Advice> advices;
  @HiveField(3)
  AdviceStatus type;

  AdviceSet({
    required this.date,
    required this.title,
    required this.advices,
    required this.type
  });

}
