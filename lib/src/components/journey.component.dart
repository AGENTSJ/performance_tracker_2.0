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
import 'package:performance_tracker/src/components/journeyIntroduction.dart';
import 'package:performance_tracker/src/components/loading.component.dart';

class JourneyComponent extends StatefulWidget {
  const JourneyComponent({Key? key}) : super(key: key);

  @override
  _JourneyComponentState createState() => _JourneyComponentState();
}

class _JourneyComponentState extends State<JourneyComponent> {
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
  double journeyCompleted = 0;
  bool userInCut = true;
  @override
  void initState() {
    super.initState();
    setupUi();
  }

  setupUi() async {
    this.currentJourney = journeyService.getActiveJourney();
    user = await userService.getUserData();
    if (currentJourney != null) {
      caloriesTotal =
          (currentJourney!.userAtStart.weight - user!.userGoals.targetWeight) *
          7700;
      estimatedDays =
          ((caloriesTotal - currentJourney!.caloriesChangeAchieved) /
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
      journeyCompleted = (caloriesAchievePercent + stepAchievePercent) / 2;
      currentBadge = journeyService.getBadge(journeyCompleted);
    }
    isLoaded = true;
    if (user!.userGoals.targetWeight <= user!.weight) {
      // user in cut
      userInCut = true;
    } else {
      // user in bulk
      userInCut = false;
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
    if (userInCut) {
      // user in cut
      calDiffAchievedToday = maintenance - calToday;
    } else {
      // user in bulk
      calDiffAchievedToday = calToday - maintenance;
    }

    currentJourney!.lastCaloriesValue ??= 0;
    currentJourney!.lastStepValue ??= 0;
    if (nowDateString != lastLoggedDate) {
      // logging a new log
      currentJourney!.lastCaloriesValue =
          currentJourney!.caloriesChangeAchieved;
      currentJourney!.lastStepValue = currentJourney!.stepsWalked;

      currentJourney!.caloriesChangeAchieved += calDiffAchievedToday;
      currentJourney!.stepsWalked += day.activity!.steps;
      currentJourney!.logs.add(JourneyLog(dayId: day.key, userAtDay: user!));
    } else {
      // updating log
      currentJourney!.caloriesChangeAchieved = currentJourney!.lastCaloriesValue! + calDiffAchievedToday;
      currentJourney!.stepsWalked = currentJourney!.lastStepValue! + day.activity!.steps;
      var lastLog = currentJourney!.logs.last;
      lastLog.dayId = day.key;
      lastLog.userAtDay = user!;
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
        logs: [],
      );
      newJourney.lastUpdated = newJourney.startDate;
      await journeyService.createJourney(newJourney);
      setupUi();
      refreshState();
    }
  }

  List<PieChartSectionData> _getSections() {
    return [
      PieChartSectionData(
        color: PRIMARY,
        value: journeyCompleted,
        title: '',
        radius: 10.r,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: BORDER_PRIMARY,
        value: (100 - journeyCompleted).clamp(0, 100),
        title: '',
        radius: 10.r,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
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
                color: SURFACE2,
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    JourneyIntroduction(),
                    SizedBox(height: 10.h),
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
                      child: Text("Start Journey"),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 100.h,
                                  width: 100.h,
                                  child: Stack(
                                    children: [
                                      PieChart(
                                        PieChartData(
                                          sections: _getSections(),
                                          sectionsSpace: 0,
                                          centerSpaceRadius: 45.r,
                                          startDegreeOffset: -90,
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: currentBadge!
                                                  .badgeImage
                                                  .image,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              100.r,
                                            ),
                                          ),
                                          height: 70.h,
                                          width: 70.h,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                        "Days Remaining",
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.fire, size: 15.sp),
                                    SizedBox(width: 10.w),
                                    Text(
                                      userInCut
                                          ? "Calories To Cut"
                                          : "Calories to gain",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${(caloriesTotal - currentJourney!.caloriesChangeAchieved).clamp(0, double.infinity).round()} Cal remaining",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: TEXT_SECONDARY,
                                  ),
                                  textAlign: TextAlign.center,
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
                                    key: ValueKey(caloriesAchievePercent),
                                    BarChartData(
                                      gridData: FlGridData(show: false),
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: 100,
                                      barTouchData: BarTouchData(
                                        enabled: false,
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
                                                  BorderRadius.circular(15.r),
                                              backDrawRodData:
                                                  BackgroundBarChartRodData(
                                                    show: true,
                                                    toY:
                                                        100, // Max value for the track
                                                    color: const Color.fromARGB(
                                                      187,
                                                      224,
                                                      224,
                                                      224,
                                                    ),
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
                                  " ${currentJourney!.caloriesChangeAchieved >= 0 ? currentJourney!.caloriesChangeAchieved.round() : 0} / ${currentJourney!.caloriesChangeAchieved >= 0 ? caloriesTotal.round() : (caloriesTotal + currentJourney!.caloriesChangeAchieved).round()} Cal",
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${(stepsTotal - currentJourney!.stepsWalked).clamp(0, double.infinity).round()} Steps remaining",
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
                                    key: ValueKey(stepAchievePercent),
                                    BarChartData(
                                      gridData: FlGridData(show: false),
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: 100,
                                      barTouchData: BarTouchData(
                                        enabled: false,
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
                                                  BorderRadius.circular(15.r),
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
                                      style: TextStyle(color: Colors.redAccent),
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
