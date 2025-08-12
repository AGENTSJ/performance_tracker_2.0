import 'package:hive_flutter/adapters.dart';
part 'advice.model.g.dart';

@HiveType(typeId: 20)
class Advice extends HiveObject {
  @HiveField(0)
  String adviceDesc;
  @HiveField(1)
  String conditions;
  @HiveField(2)
  String title;
  @HiveField(3)
  DateTime? date;

  Advice({
    required this.adviceDesc,
    required this.conditions,
    required this.title,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'adviceDesc': adviceDesc,
    'conditions': conditions,
    'title': title,
    'date': date?.toIso8601String(),
  };

  factory Advice.fromJson(Map<String, dynamic> json) => Advice(
    adviceDesc: json['adviceDesc'] as String,
    conditions: json['conditions'] as String,
    title: json['title'] as String,
    date:json['date']==null?null: DateTime.parse(json['date'] as String),
  );
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
class AdviceSet extends HiveObject {
  @HiveField(0)
  DateTime? lastUpdated;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<Advice> advices;
  @HiveField(3)
  AdviceStatus type;

  AdviceSet({
    required this.lastUpdated,
    required this.title,
    required this.advices,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'lastUpdated': lastUpdated?.toIso8601String(),
    'title': title,
    'advices': advices.map((advice) => advice.toJson()).toList(),
    'type': type.name,
  };

  factory AdviceSet.fromJson(Map<String, dynamic> json) => AdviceSet(
    lastUpdated:json['lastUpdated']==null?null: DateTime.parse(json['lastUpdated'] as String),
    title: json['title'] as String,
    advices: (json['advices'] as List<dynamic>)
        .map((adviceJson) => Advice.fromJson(adviceJson as Map<String, dynamic>))
        .toList(),
    type: AdviceStatus.values.firstWhere((e) => e.name == json['type']),
  );
}
