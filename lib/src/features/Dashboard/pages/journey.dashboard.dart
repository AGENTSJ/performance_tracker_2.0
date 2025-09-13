import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/health.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
import 'package:performance_tracker/src/features/Dashboard/widgets/calorie.chart.dart';
import 'package:performance_tracker/src/features/Dashboard/widgets/journal.lock.dart';
import 'package:performance_tracker/src/features/Dashboard/widgets/journey.graph.dart';
import 'package:performance_tracker/src/features/Dashboard/widgets/steps.chart.dart';
import 'package:performance_tracker/src/components/journey.component.dart';
import 'package:performance_tracker/src/components/loading.component.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int steps = 0;
  double? maintenance;
  var moveKm = 0.0;
  Day? day;
  User? user;
  Journey? currentJourney;
  var healthService = locator<HealthService>();
  var commonService = locator<CommonService>();
  var userGoalsService = locator<UserGoalsService>();
  var userService = locator<UserService>();
  var dayService = locator<DayService>();
  var journeyService = locator<JourneyService>();
  bool isLoading = true;
  UserGoals? userGoals;
  ScrollController daysScrollController = ScrollController();
  var smallLabelHeadingDecor = TextStyle(
    color: TEXT_SECONDARY,
    fontWeight: FontWeight.w500,
    fontSize: 12.sp,
  );
  var smallLabelDecor = TextStyle(
    color: TEXT_PRIMARY,
    fontWeight: FontWeight.w500,
    fontSize: 15.sp,
  );
  MacroNutrients? nutrientsForToday;

  @override
  void initState() {
    super.initState();
    setUpUi(DateTime.now());
  }

  setUpUi(DateTime date) async {
    userGoals = await userGoalsService.getUserGoals();
    steps = await healthService.getStepsByDate(date);
    user = await userService.getUserData();
    moveKm = await healthService.getMoveKm(date);
    day = await dayService.getDayDataByDate(date);
    nutrientsForToday = dayService.getDaysCalories(day!);
    currentJourney = journeyService.getActiveJourney();
    day!.activity!.steps = steps;
    maintenance = userGoalsService.fetchMaintenanceCalories(
      user!,
      steps: steps,
      nutrientsForToday!,
    );
    await dayService.updateDayData(day!);
    await Future.delayed(Duration(milliseconds: WAITING_PERIOD_PAGE_SWITCH_MS));
    isLoading = false;
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: day == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    commonService.getDateString(day!.dayTime),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TEXT_SECONDARY,
                      fontSize: 17.sp,
                    ),
                  ),
                ],
              ),
        backgroundColor: BACKGROUND,
        scrolledUnderElevation: 0,
      ),
      body: isLoading
          ? LoadingPage()
          : RefreshIndicator(
              onRefresh: () async {
                await setUpUi(DateTime.now());
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      // journey
                      JourneyComponent(
                        onChange: () {
                          setUpUi(DateTime.now());
                        },
                      ),
                      SizedBox(height: 20.h),
                      // current day stats
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: SURFACE2,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: BORDER_SECONDARY),
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(14.0.r),
                                    child: Text(
                                      "Todays Stats",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: BORDER_SECONDARY),
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 180.h,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.0.r,
                                        ),
                                        child: StepsChart(
                                          key: ValueKey(steps),
                                          totalCount: userGoals!.stepGoal
                                              .toDouble(),
                                          count: steps.toDouble(),
                                          centerSpace: 50,
                                          lineRadius: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 150.h,
                                      child: CalorieChart(
                                        centerSpace: 50,
                                        lineRadius: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: BORDER_SECONDARY),
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${userGoals!.stepGoal}",
                                            style: smallLabelDecor,
                                          ),
                                          SizedBox(height: 5.h),
                                          Text(
                                            "Step Goal",
                                            style: smallLabelHeadingDecor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            moveKm.toStringAsFixed(2),
                                            style: smallLabelDecor,
                                          ),
                                          SizedBox(height: 5.h),
                                          Text(
                                            "Km Traveled",
                                            style: smallLabelHeadingDecor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${(user!.weight >= user!.userGoals.targetWeight ? day!.goalForToday!.calorieLimit - day!.goalForToday!.caloricChangeGoal : day!.goalForToday!.calorieLimit + day!.goalForToday!.caloricChangeGoal).round()}",
                                            style: smallLabelDecor,
                                          ),
                                          SizedBox(height: 5.h),
                                          Text(
                                            "Calorie Goal",
                                            style: smallLabelHeadingDecor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${(maintenance!).round()}",
                                            style: smallLabelDecor,
                                          ),
                                          SizedBox(height: 5.h),
                                          Text(
                                            "Maintenance",
                                            style: smallLabelHeadingDecor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // journey tracker
                      if (currentJourney != null &&
                          (currentJourney!.status == JourneyStatus.onProgress ||
                              currentJourney!.status ==
                                  JourneyStatus.completed))
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: SURFACE2,
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: BORDER_SECONDARY),
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0.r),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Track",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(14.0.r),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: JourneyGraph(
                                    key: ValueKey(
                                      currentJourney?.caloriesChangeAchieved,
                                    ),
                                    journey: currentJourney!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20.h),
                      // journal
                      JournalLock(),
                      SizedBox(height: 20.h),

                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
