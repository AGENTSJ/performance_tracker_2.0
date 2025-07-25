import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/journey.model.dart';

class JourneyRepository {
  final _journeyBox = Hive.box<Journey>(Collections.journey.value);

  Journey? getCurrentJourneyData() {
    Journey? selectedJourney;
    for (var journey in _journeyBox.values) {
      if (journey.onProgress) {
        selectedJourney = journey;
        break;
      }
    }
    return selectedJourney;
  }

  Future<int> addJourney(Journey journey) async {
    return await _journeyBox.add(journey);
  }

  Future<void> updateJourney(int key, Journey journey) async {
    await _journeyBox.put(key, journey);
  }

  Future<void> deleteJourney(int key) async {
    await _journeyBox.delete(key);
  }
}