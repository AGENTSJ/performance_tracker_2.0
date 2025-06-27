import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/modules/nutritionModule/models/day.model.dart';
import 'package:performance_tracker/modules/nutritionModule/models/food.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/day.service.dart';
import 'package:performance_tracker/modules/nutritionModule/src/components/microNutrientList.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/nutritionAnalysis.page/widgets/macroAnalysisWidget.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/nutritionAnalysis.page/widgets/macroCommentsWidget.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/nutritionAnalysis.page/widgets/microCommentsWidget.dart';

class NutritionAnalysisPage extends StatefulWidget {
  final Day day;
  const NutritionAnalysisPage({super.key, required this.day});
  @override
  State<StatefulWidget> createState() => _NutritionAnalysisState();
}

class _NutritionAnalysisState extends State<NutritionAnalysisPage> {
  final DayService dayService = locator<DayService>();
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
    setState(() {
      setTotalConsumed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: BACKGROUND, scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              // Today analysis
              MacroAnalysisWidget(macros: todaysMacros!,totalCalLimit: totalCalLimit,),
              SizedBox(height: 30),
              MacroCommentsWidget(day: widget.day),
              SizedBox(height: 30),
              // Micro
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.seedling, size: 20),
                          SizedBox(width: 20),
                          Text(
                            'Micro Nutrients Analysis',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: microNutrientList(totalConsumed: totalConsumed,allowScroll: allowMicroScroll,),
                      ),
                      if(!allowMicroScroll)
                      TextButton(onPressed: (){handleMicroScrollEnable();}, child: Text('Show more',style: TextStyle(color: const Color.fromARGB(255, 104, 104, 104)),))
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              MicroCommentsWidget(day: widget.day, microMap: totalConsumed)
            ],
          ),
        ),
      ),
    );
  }

  handleMicroScrollEnable()
  {
    this.allowMicroScroll = true;
    setState(() {
    });
  }

  setTotalConsumed() {
    this.todaysMacros = new MacroNutrients(0, 0, 0, 0, 0);
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
  }
}

