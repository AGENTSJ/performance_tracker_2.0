import 'dart:async';

class UserGoalsService {
  // Simulated user data (replace with real API/database calls)
  final Map<String, dynamic> _userData = {
    'maintenanceCalories': 1800,
    'proteinGoal': 150, // grams
    'carbGoal': 250, // grams
    'fatGoal': 70, // grams
    'waterIntakeGoal': 3000, // ml
    'stepsGoal': 10000,
  };

  Future<double> getMaintenanceCalories() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    return _userData['maintenanceCalories'];
  }

  Future<int> getProteinGoal() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _userData['proteinGoal'];
  }

  Future<int> getCarbGoal() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _userData['carbGoal'];
  }

  Future<int> getFatGoal() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _userData['fatGoal'];
  }

  Future<int> getWaterIntakeGoal() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _userData['waterIntakeGoal'];
  }

  Future<int> getStepsGoal() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _userData['stepsGoal'];
  }

  Future<Map<String,dynamic>> getUserGoals() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _userData;
  }
}