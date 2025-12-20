import 'package:hive/hive.dart';

part 'log.model.g.dart';

@HiveType(typeId: 35)
class LogModel extends HiveObject {
  @HiveField(0)
  late String entityId;

  @HiveField(1)
  late String message;

  @HiveField(2)
  late DateTime timestamp;

  @HiveField(3)
  late String level; // 'info', 'warning', 'error', 'success'

  LogModel({
    required this.entityId,
    required this.message,
    required this.timestamp,
    this.level = 'info',
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }
}