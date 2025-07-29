import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/advice.model.dart';

class AdviceRepository {
  final _adviceBox = Hive.box<AdviceSet>(Collections.advices.value);

  List<AdviceSet> getAllAdvices() {
    return _adviceBox.values.toList();
  }

  AdviceSet? getAdvice(dynamic key) {
    return _adviceBox.get(key);
  }

  Future<void> addAdvice(AdviceSet advice) async {
    await _adviceBox.add(advice);
  }

  Future<void> updateAdvice(dynamic key, AdviceSet advice) async {
    await _adviceBox.put(key, advice);
  }

  Future<void> deleteAdvice(dynamic key) async {
    await _adviceBox.delete(key);
  }
}