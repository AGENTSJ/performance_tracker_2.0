import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Workout/models/advice.model.dart';
import 'package:performance_tracker/repositories/advice.repository.dart';

class AdviceService {
  final AdviceRepository _repository = locator<AdviceRepository>();

  List<AdviceSet> fetchAllAdvices() {
    return _repository.getAllAdvices();
  }

  AdviceSet? fetchAdviceByKey(dynamic key) {
    return _repository.getAdvice(key);
  }

  Future<int> createAdvice(AdviceSet advice) async {
    return await _repository.addAdvice(advice);
  }

  Future<void> updateAdvice(dynamic key, AdviceSet advice) async {
    await _repository.updateAdvice(key, advice);
  }

  Future<void> removeAdvice(dynamic key) async {
    await _repository.deleteAdvice(key);
  }

  Future<AdviceSet> getAdviceByStatus(AdviceStatus status)async
  {
    var advices = _repository.getAllAdvices();
    for (var adv in advices) {
      if(adv.type==status)
      {
        return adv;
      }
    }
    return advices.first;
  }

  Future<void> clearAllAdviceSet()async
  {
    await _repository.clearAllAdviceSet();
  }

}