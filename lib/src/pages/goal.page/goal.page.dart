import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:performance_tracker/src/pages/loading.page/loading.page.dart';

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
  final rumColor = Color(0xFF8B0000);
  final Color goldColor = Color(0xFFFFD700);
  Journey? currentJourney;
  User? user;
  double caloriesTotal = 0;
  int estimatedDays = 0;
  int stepsTotal = 0;
  double caloriesAchievePercent = 0;
  double stepAchievePercent = 0;
  double calDiffAchievedToday = 0;
  JourneyBadge? currentBadge;
  bool isLoaded = false;
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
          .getPercentage(caloriesTotal, currentJourney!.caloriesChangeAchieved)
          .roundToDouble()
          .clamp(0, 100);
      stepAchievePercent = commonService
          .getPercentage(
            stepsTotal.toDouble(),
            currentJourney!.stepsWalked.toDouble(),
          )
          .roundToDouble()
          .clamp(0, 100);
      var journeyCompleted = (calDiffAchievedToday + stepAchievePercent) / 2;
      this.currentBadge = journeyService.getBadge(journeyCompleted);
    }
    isLoaded = true;
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
                    child: Text("Start"),
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
    return SizedBox(
      child: !isLoaded
          ? LoadingPage()
          : currentJourney == null
          ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: SURFACE2
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
              ),
            ),
          )
          : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: SURFACE2,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.0.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: SURFACE2),
                              height: 70.h,
                              child: currentBadge!.badgeImage,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12.0.h),
                                  child: Column(
                                    children: [
                                      Text(
                                        "$estimatedDays",
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Days till we reach",
                                        style: TextStyle(
                                          color: TEXT_SECONDARY,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.fire, size: 15.sp),
                                    SizedBox(width: 10.w),
                                    Text(
                                      "Calories",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "( ${(caloriesTotal - currentJourney!.caloriesChangeAchieved).clamp(0, double.infinity).round()} Cal remaining )",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: TEXT_SECONDARY,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0.h),
                              child: SizedBox(
                                height: 20.h,
                                width: double.infinity,
                                child: RotatedBox(
                                  quarterTurns: 1,
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
                                      titlesData: FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: caloriesAchievePercent,
                                              color: rumColor,
                                              width: 20.h,
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                              backDrawRodData:
                                                  BackgroundBarChartRodData(
                                                    show: true,
                                                    toY:
                                                        100, // Max value for the track
                                                    color:
                                                        const Color.fromARGB(
                                                          187,
                                                          224,
                                                          224,
                                                          224,
                                                        ), // Your track color
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${currentJourney!.caloriesChangeAchieved.round()} / ${caloriesTotal.round()} Cal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: TEXT_TERTIARY,
                                  ),
                                ),
                              ],
                            ),
                            // Steps
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    RotatedBox(
                                      quarterTurns: 3,
                                      child: Icon(
                                        FontAwesomeIcons.shoePrints,
                                        size: 12.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      "Steps",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "( ${(stepsTotal - currentJourney!.stepsWalked).clamp(0, double.infinity).round()} Steps remaining )",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: TEXT_SECONDARY,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: SizedBox(
                                height: 20.h,
                                child: RotatedBox(
                                  quarterTurns: 1,
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
                                      titlesData: FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: stepAchievePercent,
                                              color: Colors.green,
                                              width: 20.h,
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                              backDrawRodData:
                                                  BackgroundBarChartRodData(
                                                    show: true,
                                                    toY:
                                                        100, // Max value for the track
                                                    color: Colors
                                                        .grey[300], // Your track color
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${currentJourney!.stepsWalked.round()} / ${stepsTotal.round()} Steps",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: TEXT_TERTIARY,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
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
                                        side: BorderSide(
                                          color: PRIMARY,
                                          width: 0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                    child: Text("Log Journey"),
                                  ),
                                ),
                              ],
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
                                        side: BorderSide(
                                          color: Colors.redAccent,
                                          width: 0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Stop Journey",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                      ),
                                    ),
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
    );
  }
}
