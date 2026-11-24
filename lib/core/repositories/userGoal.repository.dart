import 'package:hive_flutter/adapters.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/core/models/userGoal.model.dart';

class UserGoalRepository {
  final _goalBox = Hive.box<UserGoal>(Collections.userGoals.value);

  UserGoal? getActiveGoal() {
    for (final goal in _goalBox.values) {
      if (goal.isActive) return goal;
    }
    return null;
  }

  UserGoal? getGoalById(int id) {
    return _goalBox.get(id);
  }

  List<UserGoal> getAllGoals() {
    return _goalBox.values.toList();
  }

  Future<int> addGoal(UserGoal goal) async {
    return await _goalBox.add(goal);
  }

  Future<void> putGoal(int id, UserGoal goal) async {
    await _goalBox.put(id, goal);
  }

  Future<void> updateGoal(UserGoal goal) async {
    await _goalBox.put(goal.key, goal);
  }

  Future<void> clearAllGoals() async {
    await _goalBox.clear();
  }
}
