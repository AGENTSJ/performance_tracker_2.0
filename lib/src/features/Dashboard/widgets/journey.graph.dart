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
  State<JourneyGraph> createState() => _JourneyGraphState();
}

class _JourneyGraphState extends State<JourneyGraph> {
  final List<BarChartGroupData> barGroups = [];

  final dayService = locator<DayService>();
  final userService = locator<UserService>();
  final commonService = locator<CommonService>();
  final goalService = locator<UserGoalsService>();
  double clampPercent(double value) => value.clamp(-100, 100).round().toDouble();
  User? user;
  List<Day> days = [];
  List<_DataRepresentation> barMetaData = [];
  double graphWidth = 50;
  double widthPerPoint = 70;
  double maxY = 0;
  bool isUserInCut = true;

  @override
  void initState() {
    super.initState();
    _setUpUi();
  }

  Future<void> _setUpUi() async {
    user = await userService.getUserData();
    await _setUpGraphData();
    if (mounted) setState(() {});
  }
  _DataRepresentation _getCaloriesAndStepDataByLog(Day day , JourneyLog log)
  {
    final calories = dayService.getDaysCalories(day);
    final maintenance = day.goalForToday!.calorieLimit;
    double calorieChangePercentage;
    if (log.userAtDay.userGoals.targetWeight <
        widget.journey.userAtStart.weight) {
      isUserInCut = true;
      calorieChangePercentage = ((maintenance - calories.calories) / log.userAtDay.userGoals.calorieLimit)*100;
    } else {
      isUserInCut = false;
      calorieChangePercentage = calories.calories - maintenance;
    }

    var stepChangeGoalPerentage = (3000 / log.userAtDay.userGoals.stepGoal)*100;
    return _DataRepresentation(calorieGraphValue: clampPercent(calorieChangePercentage), stepGraphValue: clampPercent(stepChangeGoalPerentage), caloriePercentage: calorieChangePercentage.round().toDouble(), stepsPercentage: stepChangeGoalPerentage.round().toDouble());
  }
  Future<void> _setUpGraphData() async {
    final count = widget.journey.logs.length;
    barMetaData = [];
    
    for (int i = 0; i < count; i++) {
      final log = widget.journey.logs[i];
      final day = dayService.getDayById(log.dayId)!;
      days.add(day);
      var data = _getCaloriesAndStepDataByLog(day, log);
      barMetaData.add(data);
      maxY = max(
        maxY,
        max(data.stepGraphValue, data.calorieGraphValue) + 10
      );
      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 6,
          barRods: [
            /// Steps
            BarChartRodData(
              toY: data.stepGraphValue ,
              width: 8.w,
              color: PRIMARY,
              borderRadius: BorderRadius.circular(4),
            ),
            /// Calories (Deficit / Surplus)
            BarChartRodData(
              toY: data.calorieGraphValue,
              width: 8.w,
              color: CALORIE_COLOR,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    graphWidth = widthPerPoint * count;
  }

  @override
  Widget build(BuildContext context) {
    if (barGroups.isEmpty) {
      return SizedBox(
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
      );
    }

    return SizedBox(
      height: 200.h,
      width: graphWidth.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: BarChart(
          BarChartData(
            minY: -100,
            maxY: 100,
            alignment: BarChartAlignment.spaceBetween,
            barGroups: barGroups,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  var label = '';
                  var labelData = '';
                  if(rodIndex == 0) // step
                  {
                    label = 'Steps';
                    labelData = "${barMetaData[groupIndex].stepsPercentage}%";
                  }
                  else
                  {
                    label = isUserInCut
                          ? "Deficit"
                          : "Surplus";
                    labelData = "${barMetaData[groupIndex].caloriePercentage}%";
                  }
                  return BarTooltipItem(
                      "$label : $labelData",
                      TextStyle(color: TEXT_SECONDARY),
                    );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(),
              topTitles: AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45.sp,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= days.length) return const SizedBox();

                    final date = commonService
                        .getDateString(days[index].dayTime)
                        .split(' ');

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 4.h),
                        Text(
                          date[0],
                          style: TextStyle(
                            color: TEXT_TERTIARY,
                            fontSize: 10.sp,
                          ),
                        ),
                        Text(
                          "${date[1].substring(0, 3)} ${date[2]}",
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
            ),
            extraLinesData:ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 100,
                  color: TEXT_TERTIARY,
                  strokeWidth: 1,
                ),
              ]
            ) 
          ),
        ),
      ),
    );
  }
}

class _DataRepresentation {
  double calorieGraphValue;
  double stepGraphValue;
  double caloriePercentage;
  double stepsPercentage;
  _DataRepresentation({required this.calorieGraphValue,required this.stepGraphValue,required this.caloriePercentage,required this.stepsPercentage});
}