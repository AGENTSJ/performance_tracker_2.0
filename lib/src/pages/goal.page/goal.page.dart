import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
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
  var userGoalService = locator<UserGoalsService>();
  var commonService = locator<CommonService>();
  var dayService = locator<DayService>();

  Journey? currentJourney;
  User? user;
  double caloriesTotal = 0;
  int estimatedDays = 0;
  int stepsTotal = 0;
  double caloriesAchievePercent = 0;
  double stepAchievePercent = 0;
  double calDiffAchievedToday = 0;
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
      caloriesAchievePercent = commonService
          .getPercentage(caloriesTotal, 2000)
          .roundToDouble()
          .clamp(0, 100);
      stepAchievePercent = commonService
          .getPercentage(stepsTotal.toDouble(), 2000)
          .roundToDouble()
          .clamp(0, 100);
    }
    refreshState();
  }

  handleRestart() async {
    currentJourney!.onProgress = false;
    await this.journeyService.updateJourney(currentJourney!);
    currentJourney = null;
    setupUi();
  }

  handleLogJourney() async {
    var nowDateString = commonService.getDateString(DateTime.now());
    var lastLoggedDate = commonService.getDateString(
      currentJourney!.lastUpdated!,
    );
    var day = await dayService.getDayDataByDate(DateTime.now());
    var maintenance = userGoalService.fetchMaintenanceCalories(
      user!,
      steps: day!.activity!.steps,
    );
    var calToday = dayService.getDaysCalories(day).calories;
    calDiffAchievedToday = maintenance - calToday;
    currentJourney!.lastCaloriesValue ??= 0;
    currentJourney!.lastStepValue ??= 0;
    if (nowDateString != lastLoggedDate) {
      currentJourney!.lastCaloriesValue =
          currentJourney!.caloriesChangeAchieved;
      currentJourney!.lastStepValue = currentJourney!.stepsWalked;

      currentJourney!.caloriesChangeAchieved += calDiffAchievedToday;
      currentJourney!.stepsWalked += day.activity!.steps;
    } else {
      currentJourney!.caloriesChangeAchieved =
          currentJourney!.lastCaloriesValue! + calDiffAchievedToday;
      currentJourney!.stepsWalked =
          currentJourney!.lastStepValue! + day.activity!.steps;
    }
    await journeyService.updateJourney(currentJourney!);
    refreshState();
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
      );
      newJourney.lastUpdated = newJourney.startDate;
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
                  Container(
                    height: 400.h,
                    child: Column(
                      children: [
                        Row(children: [Text("$estimatedDays")]),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Column(
                                          children: [
                                            Text(
                                              "${(caloriesTotal - currentJourney!.caloriesChangeAchieved).round()}",
                                            ),
                                            Text("More to go"),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: BarChart(
                                          BarChartData(
                                            gridData: FlGridData(show: false),
                                            alignment:
                                                BarChartAlignment.spaceAround,
                                            maxY: 100,
                                            barTouchData: BarTouchData(
                                              enabled: true,
                                              touchTooltipData: BarTouchTooltipData(
                                                tooltipPadding:
                                                    const EdgeInsets.all(8),
                                                getTooltipItem:
                                                    (
                                                      group,
                                                      groupIndex,
                                                      rod,
                                                      rodIndex,
                                                    ) {
                                                      return BarTooltipItem(
                                                        '${currentJourney!.caloriesChangeAchieved.round()}\n',
                                                        const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                            titlesData: FlTitlesData(
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                        final titles = [
                                                          'Calories',
                                                        ];
                                                        return Text(
                                                          titles[value.toInt()],
                                                        );
                                                      },
                                                  reservedSize: 30,
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            barGroups: [
                                              BarChartGroupData(
                                                x: 0,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: caloriesAchievePercent,
                                                    color: Colors.blue,
                                                    width: 100.w,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2.r,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Column(
                                          children: [
                                            Text(
                                              "${stepsTotal - this.currentJourney!.stepsWalked}",
                                            ),
                                            Text("More to go"),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: BarChart(
                                          BarChartData(
                                            gridData: FlGridData(show: false),
                                            alignment:
                                                BarChartAlignment.spaceAround,
                                            maxY: 100,
                                            barTouchData: BarTouchData(
                                              enabled: true,
                                              touchTooltipData: BarTouchTooltipData(
                                                tooltipPadding:
                                                    const EdgeInsets.all(8),
                                                getTooltipItem:
                                                    (
                                                      group,
                                                      groupIndex,
                                                      rod,
                                                      rodIndex,
                                                    ) {
                                                      return BarTooltipItem(
                                                        '${currentJourney!.stepsWalked.round()}\n',
                                                        const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                            titlesData: FlTitlesData(
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                        final titles = [
                                                          'Steps',
                                                        ];
                                                        return Text(
                                                          titles[value.toInt()],
                                                        );
                                                      },
                                                  reservedSize: 30,
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            barGroups: [
                                              BarChartGroupData(
                                                x: 0,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: stepAchievePercent,
                                                    color: Colors.green,
                                                    width: 100.w,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2.r,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            handleLogJourney();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: SURFACE2,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: PRIMARY, width: 0.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text("Log Journey"),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
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
                              side: BorderSide(
                                color: Colors.redAccent,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            "Stop journey",
                            style: TextStyle(color: Colors.redAccent),
                          ),
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
