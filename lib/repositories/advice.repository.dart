import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/advice.model.dart';

class AdviceRepository
{
  final _adviceBox = Hive.box<Advice>(Collections.advices.value);

  List<Advice> getAllAdvices()
  {
    return _adviceBox.values.toList();
  }
  
}