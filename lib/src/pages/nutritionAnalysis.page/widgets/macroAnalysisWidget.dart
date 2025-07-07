import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/src/components/AnimatedProgressBar.dart';
import 'package:performance_tracker/src/components/macroPieChart.dart';
import 'package:performance_tracker/constants.ui.dart';

class MacroAnalysisWidget extends StatelessWidget {
  final MacroNutrients macros;
  final double totalCalLimit;
  final commonService = locator<CommonService>();
  final String unit = 'g';

  MacroAnalysisWidget({
    super.key,
    required this.macros,
    required this.totalCalLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: CONT_BACKGROUND,
      ),
      constraints: BoxConstraints(maxHeight: 310.h),
      child: Padding(
        padding: EdgeInsets.all(14.0.w),
        child: Column(
          children: [
            // heading
            Row(
              children: [
                Text(
                  'Macro Nutrient Analysis',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.sp),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // calories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(macros.calories>0) ...[
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  width: 90.w,
                  height: 90.h,
                  child: MacroPieChart(
                    totalCalories: macros.calories,
                    fats: macros.fat,
                    carbs: macros.carbohydrate,
                    protein: macros.protein,
                  ),
                ),
                ]
                else
                ...[
                  Padding(
                    padding: EdgeInsets.all(8.0.w),
                    child: Icon(FontAwesomeIcons.solidFaceLaughWink,size: 75.w,color: const Color.fromARGB(150, 158, 158, 158),),
                  )
                ],
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${macros.calories.round()} / ${totalCalLimit.round()} Cal",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 1.h,
                              width: double.infinity,
                              child: AnimatedProgressBar(
                                key: ValueKey(macros.calories),
                                value:
                                    (commonService.getPercentage(
                                      totalCalLimit,
                                      macros.calories,
                                    ) /
                                    100),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Text(
                              "${commonService.getPercentage(totalCalLimit, macros.calories).round()} %",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 22.sp,
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
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: PROTEIN_COLOR, size: 16.w),
                          SizedBox(width: 20.w),
                          Text(
                            'Protein',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(
                        "${macros.protein.round().toString()} $unit",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: CARBS_COLOR, size: 16.w),
                          SizedBox(width: 20.w),
                          Text(
                            'Carbohydrate',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(
                        "${macros.carbohydrate.round().toString()} $unit",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: FAT_COLOR, size: 16.w),
                          SizedBox(width: 20.w),
                          Text(
                            'Fat',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(
                        "${macros.fat.round().toString()} $unit",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: FIBER_COLOR, size: 16.w),
                          SizedBox(width: 20.w),
                          Text(
                            'Fiber',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(
                        "${macros.fiber.round().toString()} $unit",
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
    );
  }
}
