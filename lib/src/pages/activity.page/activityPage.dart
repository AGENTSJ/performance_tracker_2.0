import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/health.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
import 'package:performance_tracker/src/pages/activity.page/steps.chart.dart';
import 'package:performance_tracker/src/pages/loading.page/loading.page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int steps = 0;
  Duration? moveMin;
  var moveKm = 0.0;
  Day? day;
  var healthService = locator<HealthService>();
  var userGoalsService = locator<UserGoalsService>();
  var commonService = locator<CommonService>();
  var dayService = locator<DayService>();
  bool isLoading = true;
  UserGoals? userGoals;
  List<Day> previousDays = [];
  ScrollController daysScrollController = ScrollController();
  var smallLabelHeadingDecor = TextStyle(
    color: TEXT_SECONDARY,
    fontWeight: FontWeight.w500,
  );
  var smallLabelDecor = TextStyle(
    color: PRIMARY,
    fontWeight: FontWeight.w600,
    fontSize: 17.sp,
  );
  bool daysLoading = false;
  int daysLoaded = 0;

  @override
  void initState() {
    super.initState();
    setUpUi(DateTime.now(), false);
    daysScrollController.addListener(() async {
      if (daysScrollController.hasClients &&
          (daysScrollController.position.pixels >=
              daysScrollController.position.maxScrollExtent - 10)) {
        await setUpActivityTab();
        refreshState();
      }
    });
  }

  setUpUi(DateTime date, bool refresh) async {
    userGoals = await userGoalsService.getUserGoals();
    steps = await healthService.getStepsByDate(date);
    moveMin = await healthService.getMoveMin(date);
    moveKm = await healthService.getMoveKm(date);
    day = await dayService.getDayDataByDate(date);
    day!.activity!.steps = steps;
    await dayService.updateDayData(day!);
    if (!refresh) {
      await setUpActivityTab();
    }
    await Future.delayed(Duration(milliseconds: WAITING_PERIOD_PAGE_SWITCH_MS));
    isLoading = false;
    refreshState();
  }

  setUpActivityTab() async {
    if (daysLoading) {
      return;
    }
    daysLoading = true;
    refreshState();
    const dayLimit = 6;
    var now = DateTime.now();
    for (var i = daysLoaded; i <= dayLimit + daysLoaded; i++) {
      var date = now.subtract(Duration(days: i));
      var day = await dayService.getDayDataByDate(date);
      var steps = await healthService.getStepsByDate(date);
      if (day!.activity!.steps < steps) {
        day.activity!.steps = steps;
        await dayService.updateDayData(day);
      }
      previousDays.add(day!);
    }
    daysLoaded = daysLoaded + 7;
    daysLoading = false;
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
                daysLoaded = 0;
                previousDays = [];
                await setUpUi(DateTime.now(), true);
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        height: 180.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0.r),
                          child: StepsChart(
                            key: ValueKey(steps),
                            totalCount: userGoals!.stepGoal.toDouble(),
                            count: steps.toDouble(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${moveMin!.inMinutes}",
                                  style: smallLabelDecor,
                                ),
                                SizedBox(height: 5.h),
                                Text("Move Min", style: smallLabelHeadingDecor),
                              ],
                            ),
                          ),
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
                                  "Current Goal",
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
                                Text("Total Km", style: smallLabelHeadingDecor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            Text(
                              "Track records",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                                color: TEXT_TERTIARY,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: daysScrollController,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ...previousDays.map(
                              (day) => Material(
                                color: SURFACE2,
                                borderRadius: BorderRadius.circular(8.r),
                                child: InkWell(
                                  onTap: () {
                                    // isLoading = true;
                                    // refreshState();
                                    // setUpUi(day.dayTime, true);
                                  },
                                  child: Container(
                                    width: 90.w,
                                    height: 150.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: BORDER_PRIMARY),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.0.w,
                                        vertical: 12.h,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 40.h,
                                            child: Stack(
                                              children: [
                                                StepsChart(
                                                  lineRadius: 9,
                                                  centerSpace: 17,
                                                  showCenterPart: false,
                                                  totalCount: day
                                                      .goalForToday!
                                                      .stepGoal
                                                      .toDouble(),
                                                  count: day.activity!.steps
                                                      .toDouble(),
                                                ),
                                                Positioned(
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    child: Center(
                                                      child: RotatedBox(
                                                        quarterTurns: 3,
                                                        child: Icon(
                                                          FontAwesomeIcons
                                                              .shoePrints,
                                                          size: 10.sp,
                                                          color: PRIMARY,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                "${day.activity!.steps}",
                                                style: TextStyle(
                                                  color: PRIMARY,
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          Text(
                                            "${day.dayTime.day}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: TEXT_SECONDARY,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            Months
                                                .values[day.dayTime.month]
                                                .name,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: TEXT_SECONDARY,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
