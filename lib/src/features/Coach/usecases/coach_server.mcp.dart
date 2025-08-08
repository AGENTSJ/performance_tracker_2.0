import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/services/advice.service.dart';

class CoachServerMcp {
  final adviceService  = locator<AdviceService>();

  Future<void> updateAdviceSets({List<AdviceSet>? advices})async
  {
    if(advices == null)return;

    await adviceService.clearAllAdviceSet();
    for (var advSet in advices) {
      var set = AdviceSet(advices: [],lastUpdated: DateTime.now(),title: advSet.title,type: advSet.type);
      for(var adv in advSet.advices)
      {
        var newAdv = Advice(adviceDesc: adv.adviceDesc, conditions: adv.conditions, title: adv.title, date: DateTime.now());
        set.advices.add(newAdv);
      }
      adviceService.createAdvice(advSet);
    }
  }

  String getKnowledgeBase() 
  {
    String adviceKnowledge = "advices : ";
    var adviceSets = adviceService.fetchAllAdvices();
    for(var advSet in adviceSets)
    {
      String setRep = advSet.toJson().toString();
      adviceKnowledge+=setRep;
    }
    return adviceKnowledge;
  }
}