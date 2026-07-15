import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/fatigue.model.dart';

class FatigueRepository {
  final _box = Hive.box<FatigueDay>(Collections.fatigue.value);

  FatigueDay? getByDateKey(String dateKey) {
    return _box.get(dateKey);
  }

  Future<void> upsert(FatigueDay day) async {
    await _box.put(day.dateKey, day);
  }

  List<FatigueDay> getAll() {
    return _box.values.toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
