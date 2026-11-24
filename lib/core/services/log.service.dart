// services/log_service.dart
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/core/models/log.model.dart';
import 'package:performance_tracker/core/repositories/log.repository.dart';

class LogService {
  final LogRepository _repository = locator<LogRepository>();

  LogService();

  Future<void> addLog(
    String entityId,
    String message, {
    String level = 'info',
  }) async {
    final log = LogModel(
      entityId: entityId,
      message: message,
      timestamp: DateTime.now(),
      level: level,
    );
    await _repository.addLog(log);
  }

  Future<void> addInfoLog(String entityId, String message) async {
    await addLog(entityId, message, level: 'info');
  }

  Future<void> addSuccessLog(String entityId, String message) async {
    await addLog(entityId, message, level: 'success');
  }

  Future<void> addWarningLog(String entityId, String message) async {
    await addLog(entityId, message, level: 'warning');
  }

  Future<void> addErrorLog(String entityId, String message) async {
    await addLog(entityId, message, level: 'error');
  }

  Future<void> removeLogsByEntityId(String entityId) async {
    await _repository.removeLogById(entityId);
  }

  Future<void> clearAllLogs() async {
    await _repository.removeAllLogs();
  }

  List<LogModel> getAllLogs() {
    return _repository.getAllLogs();
  }

  List<LogModel> getLogsByEntityId(String entityId) {
    return _repository.getLogsByEntityId(entityId);
  }
}