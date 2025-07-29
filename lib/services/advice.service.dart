import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/repositories/advice.repository.dart';

class AdviceService {
  final AdviceRepository _repository = locator<AdviceRepository>();

  List<AdviceSet> fetchAllAdvices() {
    return _repository.getAllAdvices();
  }

  AdviceSet? fetchAdviceByKey(dynamic key) {
    return _repository.getAdvice(key);
  }

  Future<void> createAdvice(AdviceSet advice) async {
    await _repository.addAdvice(advice);
  }

  Future<void> updateAdvice(dynamic key, AdviceSet advice) async {
    await _repository.updateAdvice(key, advice);
  }

  Future<void> removeAdvice(dynamic key) async {
    await _repository.deleteAdvice(key);
  }
}