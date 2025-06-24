import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/src/components/macroPieChart.dart';
import 'package:performance_tracker/src/components/AnimatedProgressBar.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class NutritionAnalysisPage extends StatefulWidget {
  final Day day;
  const NutritionAnalysisPage({super.key, required this.day});
  @override
  State<StatefulWidget> createState() => _NutritionAnalysisState();
}

class _NutritionAnalysisState extends State<NutritionAnalysisPage> {
  final DayService dayService = locator<DayService>();
  double protein = 0;
  double fat = 0;
  double carbohydrate = 0;
  double fiber = 0;
  String unit = 'g';
  Map<String, MeasuredUnit> totalConsumed = {};
  double totalCalLimit = 2000;
  double totalCalConsumed = 0.0;
  var commonService = locator<CommonService>();
  late List<PieChartSectionData> pieChartData = [];
  final Color proteinColor = Color(0xFF42A5F5); // Blue
  final Color fatColor = Color(0xFFFFA726); // Orange
  final Color carbohydrateColor = Color(0xFF66BB6A); // Green
  final Color fiberColor = Color(0xFFAB47BC);

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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                constraints: BoxConstraints(maxHeight: 310),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      // heading
                      Row(
                        children: [
                          Text(
                            'Todays Analysis',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // calories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            width: 90,
                            height: 90,
                            child: MacroPieChart(
                              totalCalories: totalCalConsumed,
                              fats: fat,
                              carbs: carbohydrate,
                              protein: protein,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${totalCalConsumed.round()} / ${totalCalLimit.round()} Cal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        height: 1,
                                        width: double.infinity,
                                        child: AnimatedProgressBar(
                                          value:
                                              (commonService.getPercentage(
                                                totalCalLimit,
                                                totalCalConsumed,
                                              ) /
                                              100),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        "${commonService.getPercentage(totalCalLimit, totalCalConsumed).round()} %",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: proteinColor,
                                      size: 16,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Protein',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${protein.round().toString()} $unit",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: carbohydrateColor,
                                      size: 16,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Carbohydrate',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${carbohydrate.round().toString()} $unit",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: fatColor,
                                      size: 16,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Fat',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${fat.round().toString()} $unit",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: fiberColor,
                                      size: 16,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Fiber',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${fiber.round().toString()} $unit",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                        child: ListView(
                          children: totalConsumed.entries.map((entry) {
                            final MeasuredUnit? microNutrient = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 3.0,
                                bottom: 3.0,
                                left: 8,
                                right: 8,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: (){},
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [
                                          Icon(Icons.circle,color: Colors.grey,size: 14,),
                                          SizedBox(width: 10,),
                                          SizedBox(
                                            width: 110,
                                            child: Text(
                                              entry.key,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          microNutrient != null
                                              ? '${commonService.getPercentage(MicroNutrients.microRDA[entry.key]!.value, microNutrient.value).round()}%'
                                              : '-',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              microNutrient != null
                                                  ? '${microNutrient.value.toStringAsFixed(1)} '
                                                  : '-',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(microNutrient!.unit,style: TextStyle(color: const Color.fromARGB(255, 131, 131, 131)),)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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

  setTotalConsumed() {
    for (var micro in MicroNutrients.microRDA.entries) {
      totalConsumed[micro.key] = MeasuredUnit(value: 0, unit: micro.value.unit);
    }

    for (var meal in widget.day.meals!) {
      for (var food in meal.foods) {
        protein += food.macros.protein;
        carbohydrate += food.macros.carbohydrate;
        fat += food.macros.fat;
        fiber += food.macros.fiber;
        totalCalConsumed += food.macros.calories;

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
