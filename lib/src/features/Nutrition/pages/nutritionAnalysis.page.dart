import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
import 'package:performance_tracker/src/components/microNutrientList.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Nutrition/widgets/macroAnalysisWidget.dart';
import 'package:performance_tracker/src/features/Nutrition/widgets/macroCommentsWidget.dart';
import 'package:performance_tracker/src/features/Nutrition/widgets/microCommentsWidget.dart';

class NutritionAnalysisPage extends StatefulWidget {
  final Day day;
  const NutritionAnalysisPage({super.key, required this.day});
  @override
  State<StatefulWidget> createState() => _NutritionAnalysisState();
}

class _NutritionAnalysisState extends State<NutritionAnalysisPage> {
  final DayService dayService = locator<DayService>();
  final UserGoalsService userGoalService = locator<UserGoalsService>();
  MacroNutrients? todaysMacros;
  String unit = 'g';
  Map<String, MeasuredUnit> totalConsumed = {};
  double totalCalLimit = 2000;
  double totalCalConsumed = 0.0;
  var commonService = locator<CommonService>();
  late List<PieChartSectionData> pieChartData = [];
  bool allowMicroScroll = false;

  @override
  void initState() {
    super.initState();
    setTotalConsumed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: BACKGROUND, scrolledUnderElevation: 0,foregroundColor: TEXT_PRIMARY,),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(14.0.w),
          child: Column(
            children: [
              // Today analysis
              MacroAnalysisWidget(
                macros: todaysMacros!,
                totalCalLimit: totalCalLimit,
              ),
              SizedBox(height: 30.h),
              MacroCommentsWidget(day: widget.day),
              SizedBox(height: 30.h),
              // Micro
              Container(
                decoration: BoxDecoration(
                  color: CONT_BACKGROUND,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                width: double.infinity,
                height: 300.h,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: BORDER_SECONDARY),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.0.w,
                          vertical: 16.h,
                        ),

                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.seedling, size: 20.w),
                            SizedBox(width: 20.w),
                            Text(
                              'Micro Nutrients Analysis',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(height: 20.h),
                    Expanded(
                      child: microNutrientList(
                        totalConsumed: totalConsumed,
                        allowScroll: allowMicroScroll,
                      ),
                    ),
                    if (!allowMicroScroll)
                      TextButton(
                        onPressed: () {
                          handleMicroScrollEnable();
                        },
                        child: Text(
                          'Show more',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              MicroCommentsWidget(day: widget.day, microMap: totalConsumed),
            ],
          ),
        ),
      ),
    );
  }

  handleMicroScrollEnable() {
    this.allowMicroScroll = true;
    setState(() {});
  }

  setTotalConsumed() async {
    this.todaysMacros = new MacroNutrients(0, 0, 0, 0, 0);
    var goal = widget.day.goalForToday;
    totalCalLimit = goal!.calorieLimit;
    for (var micro in MicroNutrients.microRDA.entries) {
      totalConsumed[micro.key] = MeasuredUnit(value: 0, unit: micro.value.unit);
    }

    for (var meal in widget.day.meals!) {
      for (var food in meal.foods) {
        todaysMacros?.protein += food.macros.protein;
        todaysMacros?.fat += food.macros.fat;
        todaysMacros?.carbohydrate += food.macros.carbohydrate;
        todaysMacros?.fiber += food.macros.fiber;
        todaysMacros?.calories += food.macros.calories;

        for (var micro in food.micros.microMap.entries) {
          var totalMicro = totalConsumed[micro.key];
          if (totalMicro != null) {
            totalMicro.value =
                totalMicro.value +
                (micro.value != null ? micro.value!.value : 0);
          }
        }
      }
    }
    setState(() {});
  }
}
