import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/src/features/Workout/models/fatigue.model.dart';

/// Fatigue records, keyed by the id of the track entry each belongs to.
class FatigueRepository {
  final _box = Hive.box<FatigueEntry>(Collections.fatigueEntries.value);

  /// Every record, by track entry id.
  Map<String, FatigueEntry> getAllById() {
    return {for (final record in _box.values) record.trackEntryId: record};
  }

  List<FatigueEntry> getAll() {
    return _box.values.toList();
  }

  Iterable<String> get ids => _box.keys.cast<String>();

  Future<void> put(FatigueEntry record) async {
    await _box.put(record.trackEntryId, record);
  }

  Future<void> putAll(Iterable<FatigueEntry> records) async {
    await _box.putAll({
      for (final record in records) record.trackEntryId: record,
    });
  }

  Future<void> deleteAll(Iterable<String> trackEntryIds) async {
    await _box.deleteAll(trackEntryIds);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
