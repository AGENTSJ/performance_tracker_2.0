import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/repositories/journey.repository.dart';
import 'package:performance_tracker/services/day.service.dart';

class JourneyService {
  var journeyRepo = locator<JourneyRepository>();
  var dayService = locator<DayService>();

  Journey? getActiveJourney() {
    return journeyRepo.getCurrentJourneyData();
  }
  
  Future<int> createJourney(Journey journey) async {
    return journeyRepo.addJourney(journey);
  }

  updateJourney(Journey journey) async {
    journey.lastUpdated = DateTime.now();
    return journeyRepo.updateJourney(journey.key,journey);
  }

  deleteJourney(int journeyId) async {
    return journeyRepo.deleteJourney(journeyId);
  }
}