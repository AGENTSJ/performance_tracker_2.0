import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Dashboard/models/journey.model.dart';
import 'package:performance_tracker/src/features/Dashboard/repositories/journey.repository.dart';
class JourneyBadge
{
  String title;
  Image badgeImage;
  JourneyBadge({required this.title, required this.badgeImage});
}
class JourneyService {
  final  _journeyRepo = locator<JourneyRepository>();
  final beginnerBadge = JourneyBadge(title: "Beginner", badgeImage: Image.asset("assets/1Badge.png",));
  final proBadge = JourneyBadge(title: "Pro", badgeImage: Image.asset("assets/2Badge.png",));
  final advancedBadge = JourneyBadge(title: "Advanced", badgeImage: Image.asset("assets/3Badge.png",));
  final conquerBadge = JourneyBadge(title: "Conquer", badgeImage: Image.asset("assets/4Badge.png",));
  
  Journey? getActiveJourney() {
    return _journeyRepo.getCurrentJourneyData();
  }
  
  Future<int> createJourney(Journey journey) async {
    return _journeyRepo.addJourney(journey);
  }

  updateJourney(Journey journey) async {
    journey.lastUpdated = DateTime.now();
    return _journeyRepo.updateJourney(journey.key,journey);
  }

  deleteJourney(int journeyId) async {
    return _journeyRepo.deleteJourney(journeyId);
  }

  getBadge(double percentageCompleted)
  {
    if(percentageCompleted>=0 && percentageCompleted<25)
    {
      return beginnerBadge;
    }
    if(percentageCompleted>=25 && percentageCompleted<50)
    {
      return proBadge;
    }
    if(percentageCompleted>=50 && percentageCompleted<75)
    {
      return advancedBadge;
    }
    if(percentageCompleted>=75 && percentageCompleted<100)
    {
      return conquerBadge;
    }
  }

  List<Journey> getAllJourney()
  {
    return _journeyRepo.getALLJourney();
  }
  clearAll()async
  {
    await _journeyRepo.clearAll();
  }
}