import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/src/components/goals.widget.dart';
import 'package:performance_tracker/src/pages/goal.page/journeyIntroduction.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({Key? key}) : super(key: key);

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  var journeyService = locator<JourneyService>();
  var userService = locator<UserService>();
  Journey? currentJourney;
  User? user;
  double caloriesTotal = 0;
  int estimatedDays = 0;
  int stepsTotal = 0;
  @override
  void initState() {
    super.initState();
    setupUi();
  }

  setupUi() async {
    this.currentJourney = journeyService.getActiveJourney();
    user = await userService.getUserData();
    if (this.currentJourney != null) {
      caloriesTotal =
          (currentJourney!.userAtStart.weight - user!.userGoals.targetWeight) *
          7700;
      estimatedDays =
          (caloriesTotal /
                  currentJourney!.userAtStart.userGoals.caloricChangeGoal)
              .round();
      stepsTotal =
          estimatedDays * currentJourney!.userAtStart.userGoals.stepGoal;
    }
    refreshState();
  }

  handleRestart() async {
    currentJourney!.onProgress = false;
    await this.journeyService.updateJourney(currentJourney!);
    currentJourney = null;
    setupUi();
  }

  void handleCreateJourney() async {
    bool? didUpdate = await showDialog(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.0.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: SURFACE2,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Material(
                      child: GoalsWidget(user: user!, onUpdate: () {}),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text("Start a journey"),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (didUpdate != null && didUpdate) {
      user = await userService.getUserData();
      var newJourney = Journey(
        startDate: DateTime.now(),
        userAtStart: user!,
        caloriesChangeAchieved: 0,
        stepsWalked: 0,
        onProgress: true,
        lastUpdated: null,
      );
      await journeyService.createJourney(newJourney);
      setupUi();
      refreshState();
    }
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
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
            ? Column(
                children: [
                  JourneyIntroduction(),
                  ElevatedButton(
                    onPressed: () {
                      handleCreateJourney();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text("Start a journey"),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: Container(
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final titles = [
                                    'Calories',
                                    'Steps',
                                  ];
                                  return Text(titles[value.toInt()]);
                                },
                                reservedSize: 30,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: 8,
                                  color: Colors.blue,
                                  width: 100.w,
                                  borderRadius: BorderRadius.circular(10.r)
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: 10,
                                  color: Colors.green,
                                  width: 100.w,
                                  borderRadius: BorderRadius.circular(10.r)
                                ),
                              ],
                            ),],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            handleRestart();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: SURFACE2,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: PRIMARY, width: 0.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text("Stop journey"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
