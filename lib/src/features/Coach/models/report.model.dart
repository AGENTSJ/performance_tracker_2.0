import 'package:hive/hive.dart';

part 'report.model.g.dart';

@HiveType(typeId: 30)
class Report extends HiveObject {
  @HiveField(0)
  DateTime generatedAt;

  @HiveField(1)
  DateTime entityLastUpdated;

  @HiveField(2)
  String entityId;

  @HiveField(3)
  String reportData;

  @HiveField(4)
  String entityName;

  @HiveField(5)
  EntityType type;

  Report({
    required this.generatedAt,
    required this.entityLastUpdated,
    required this.entityId,
    required this.reportData,
    required this.entityName,
    required this.type,
  });
}

@HiveType(typeId: 31)
enum EntityType {
  @HiveField(0)
  workout,
  @HiveField(1)
  routine,
  @HiveField(2)
  nutrition,
  @HiveField(3)
  activity,
  @HiveField(4)
  other,
}
