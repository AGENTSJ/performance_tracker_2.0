import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';

class ReportRepository {
  final Box<Report> _reportBox = Hive.box<Report>(Collections.reports.value);

  // Create
  Future<void> addReport(Report report) async {
    await _reportBox.add(report);
  }

  // Read all
  List<Report> getAllReports() {
    return _reportBox.values.toList();
  }

  // Read by key
  Report? getReportByKey(dynamic key) {
    return _reportBox.get(key);
  }

  // Read by entityId
  Report? getReportsByEntityId(String entityId) {
    var reports = _reportBox.values.where((r) => r.entityId == entityId).toList();
    return reports.isEmpty ? null :reports.first;
  }

  // Update
  Future<void> updateReport(dynamic key, Report report) async {
    await _reportBox.put(key, report);
  }

  // Delete
  Future<void> deleteReport(dynamic key) async {
    await _reportBox.delete(key);
  }
}