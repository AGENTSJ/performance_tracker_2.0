import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/core/models/log.model.dart';


class LogRepository {
  static const String _boxName = 'logs';

  Box<LogModel> get _box => Hive.box<LogModel>(_boxName);

  Future<void> addLog(LogModel log) async {
    await _box.add(log);
  }

  Future<void> removeLogById(String entityId) async {
    final logsToDelete = _box.values
        .where((log) => log.entityId == entityId)
        .toList();
    
    for (var log in logsToDelete) {
      await log.delete();
    }
  }

  Future<void> removeAllLogs() async {
    await _box.clear();
  }

  List<LogModel> getAllLogs() {
    return _box.values.toList().reversed.toList();
  }

  List<LogModel> getLogsByEntityId(String entityId) {
    return _box.values
        .where((log) => log.entityId == entityId)
        .toList()
        .reversed
        .toList();
  }

  List<LogModel> getLogsByLevel(String level) {
    return _box.values
        .where((log) => log.level == level)
        .toList()
        .reversed
        .toList();
  }

}
