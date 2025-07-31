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

  Report({
    required this.generatedAt,
    required this.entityLastUpdated,
    required this.entityId,
    required this.reportData,
  });
}