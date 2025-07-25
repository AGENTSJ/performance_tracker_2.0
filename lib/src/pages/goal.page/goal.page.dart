import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/src/pages/goal.page/journeyIntroduction.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({Key? key}) : super(key: key);

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  var journeyService = locator<JourneyService>();
  Journey? currentJourney;
  setupUi() {
    this.currentJourney = journeyService.getActiveJourney();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BACKGROUND,
        title: const Text('Goal Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(14.0.r),
        child: currentJourney == null
            ? JourneyIntroduction()
            : Column(children: [
            
          ],
        ),
      ),
    );
  }
}
