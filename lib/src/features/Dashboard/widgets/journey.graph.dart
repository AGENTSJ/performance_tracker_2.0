import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/services/userGoals.service.dart';

class JourneyGraph extends StatefulWidget {
  final Journey journey;
  const JourneyGraph({super.key, required this.journey});

  @override
  _JourneyGraphState createState() => _JourneyGraphState();
}

class _JourneyGraphState extends State<JourneyGraph> {
  final List<FlSpot> stepsPoints = [];
  final List<FlSpot> calPoints = [];
  var dayService = locator<DayService>();
  var userService = locator<UserService>();
  var commonService = locator<CommonService>();
  var goalService = locator<UserGoalsService>();
  User? user;
  double graphWidth = 50;
  double widthPerPoint = 50;
  bool isUserInCut = true;
  double maxY = 0;
  double maxX = 0;
  List<Day> days = [];
  @override
  void initState() {
    super.initState();
    setUpUi();
  }

  setUpUi() async {
    user = await userService.getUserData();
    await _setUpGraphData();
    refreshState();
  }

  _setUpGraphData() async {
    var count = widget.journey.logs.length;

    for (var i = 0; i < count; i++) {
      var log = widget.journey.logs[i];
      var day = dayService.getDayById(log.dayId);
      days.add(day!);
      var userAtDay = log.userAtDay;
      var calories = dayService.getDaysCalories(day);
      var maintenance = day.goalForToday!.calorieLimit;
      double calorieChangeAchieved = 0;
      if (userAtDay.userGoals.targetWeight <
          widget.journey.userAtStart.weight) {
        // user in cut
        isUserInCut = true;
        calorieChangeAchieved = maintenance - calories.calories;
      } else {
        isUserInCut = false;
        calorieChangeAchieved = calories.calories - maintenance;
      }
      maxY = max(maxY, calorieChangeAchieved + 200);
      maxY = max(maxY, day.activity!.steps.toDouble() + 1000);
      stepsPoints.add(FlSpot(i.toDouble(), day.activity!.steps.toDouble()));
      calPoints.add(FlSpot(i.toDouble(), calorieChangeAchieved));
    }
    graphWidth = widthPerPoint * count;
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return (calPoints.isEmpty && stepsPoints.isEmpty)
        ? SizedBox(
            height: 200.h,
            child: Column(
              children: [
                Expanded(child: empty),
                Text(
                  "No journey log found !!",
                  style: TextStyle(
                    color: TEXT_TERTIARY,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            height: 200.h,
            width: graphWidth.w,
            child: LineChart(
              LineChartData(
                // maxX: maxX,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,

                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final y = touchedSpot.y;
                        final lineIndex = touchedSpot.barIndex;
                        return LineTooltipItem(
                          '${lineIndex == 0
                              ? "Steps"
                              : isUserInCut
                              ? "Deficit"
                              : "Surplus"} : ${y.round()}',
                          textAlign: TextAlign.start,
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 45.sp,
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        List<String> date = commonService.getDateString(
                          days[index].dayTime,
                        ).split(' ');
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 4.h,),
                            Text(
                              date[0],
                              style: TextStyle(
                                color: TEXT_TERTIARY,
                                fontSize: 10.sp,
                              ),
                            ),
                            Text(
                              "${date[1].substring(0,3)} ${date[2]}",
                              style: TextStyle(
                                color: TEXT_TERTIARY,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: stepsPoints,
                    isCurved: false,
                    barWidth: 1,
                    color: PRIMARY,
                    dotData: FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: calPoints,
                    isCurved: false,
                    barWidth: 1,
                    color: CALORIE_COLOR,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          );
  }
}
