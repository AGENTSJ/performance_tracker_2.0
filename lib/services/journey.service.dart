import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/repositories/journey.repository.dart';

class JourneyService {
  var journeyRepo = locator<JourneyRepository>();
  
  Journey? getActiveJourney()
  {
    return journeyRepo.getCurrentJourneyData();
  }
  
  createJourney(Journey journey)async
  {
    return journeyRepo.addJourney(journey);
  }
}