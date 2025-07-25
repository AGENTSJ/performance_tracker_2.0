import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/repositories/journey.repository.dart';

class JourneyService {
  var journeyRepo = locator<JourneyRepository>();
  
  Journey? getActiveJourney() {
    return journeyRepo.getCurrentJourneyData();
  }
  
  Future<int> createJourney(Journey journey) async {
    return journeyRepo.addJourney(journey);
  }

  updateJourney(Journey journey) async {
    return journeyRepo.updateJourney(journey.key,journey);
  }

  deleteJourney(int journeyId) async {
    return journeyRepo.deleteJourney(journeyId);
  }
}