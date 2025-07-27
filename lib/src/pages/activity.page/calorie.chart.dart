import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/src/pages/loading.page/loading.page.dart';

class CalorieChart extends StatefulWidget {
  final double centerSpace;
  final double lineRadius;

  const CalorieChart({super.key, this.centerSpace = 80, this.lineRadius = 20});

  @override
  _CalorieChartState createState() => _CalorieChartState();
}

class _CalorieChartState extends State<CalorieChart> {
  var commonService = locator<CommonService>();
  var dayService = locator<DayService>();
  MacroNutrients? macroForToday;
  Day? day;
  bool isLoaded = false;
  @override
  void initState() {
    setUpUi();
    super.initState();
  }

  setUpUi() async {
    day = await dayService.getDayDataByDate(DateTime.now());
    macroForToday = dayService.getDaysCalories(day!);
    isLoaded = true;
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  _getCalChartSections() {
    var limit = day!.goalForToday!.calorieLimit;
    double value = commonService.getPercentage(limit, macroForToday!.calories);
    return [
      PieChartSectionData(
        value: value,
        color: CALORIE_COLOR,
        radius: widget.lineRadius.r,
        showTitle: false,
      ),
      PieChartSectionData(
        value: (100 - value.clamp(0, 100)),
        color: BORDER_PRIMARY,
        radius: widget.lineRadius.r,
        showTitle: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return !isLoaded
        ? LoadingPage()
        : Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: _getCalChartSections(),
                        centerSpaceRadius: widget.centerSpace.r,
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${macroForToday!.calories.round()}",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: TEXT_SECONDARY,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Icon(
                                FontAwesomeIcons.apple,
                                size: 20.sp,
                                color: CALORIE_COLOR,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
