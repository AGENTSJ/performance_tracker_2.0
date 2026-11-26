import 'package:health/health.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/core/services/day.service.dart';
import 'package:performance_tracker/core/models/activity.model.dart';

class HealthService {
  late Health _health;
  bool _authorized = false;
  bool Function()? authorized;
  final _commonService = locator<CommonService>();
  final _dayService = locator<DayService>();
  HealthService() {
    _health = Health();
    _health.configure();
    authorized = () => _authorized;
  }
  Future<bool> _makeHealthServiceAvailable() async {
    if (!_authorized) {
      if (!(await _health.isHealthConnectAvailable())) {
        print("Health Connect not available. Prompting user to install...");
        return false;
      }
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ_WRITE];
      this._authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      return _authorized;
    } else {
      return true;
    }
  }

  Future<int> getStepsByDate(DateTime date) async {
    bool valid = await _makeHealthServiceAvailable();
    if (!valid) {
      return 0;
    }
    final morningStart = DateTime(date.year, date.month, date.day);
    final night = morningStart.add(Duration(hours: 23,minutes: 59));
    int? steps = await _health.getTotalStepsInInterval(morningStart, night);
    steps ??= 0;
    if(_commonService.getDateString(DateTime.now())==_commonService.getDateString(date))
    {
      // Keep today's steps on the day; maintenance is recalculated from them.
      var day = await _dayService.getDayDataByDate(date);
      day!.activity ??= Activity(steps: 0);
      day.activity!.steps = steps;
      _dayService.updateDayData(day);
    }
    return steps;
  }

    Duration getMoveMin(int steps) {
    const secondToTakeAStep = 0.5;
    var totalSeconds = (steps * secondToTakeAStep).round();
    return Duration(seconds: totalSeconds);
  }

  Future<double> getMoveKm(DateTime date) async {
    bool valid = await _makeHealthServiceAvailable();
    if (!valid) {
      return 0;
    }
    const metersInOneStep = 0.762;
    var steps = await getStepsByDate(date);
    var totalMeters = (steps * metersInOneStep).round();
    var totalKm = totalMeters / 1000;
    return totalKm;
  }
}
