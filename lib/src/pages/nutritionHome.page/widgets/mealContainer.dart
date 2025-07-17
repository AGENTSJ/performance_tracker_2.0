import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/pages/foodEntry.page/foodEntry.page.dart';
import 'package:performance_tracker/src/pages/mealTracker.page/mealTracker.dart';

class MealContainer extends StatefulWidget {
  final Meal meal;
  final Day day;
  final ValueChanged onMealUpdated;

  const MealContainer({
    super.key,
    required this.meal,
    required this.day,
    required this.onMealUpdated,
  });

  @override
  State<MealContainer> createState() => _MealContainerState();
}

class _MealContainerState extends State<MealContainer>
    with AutomaticKeepAliveClientMixin {
  late double caloriesInMeal = 0;
  var dayService = locator<DayService>();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    setCalories(false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0.h, bottom: 8.0.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.meal.mealName,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
              ),
              Row(
                children: [
                  Text("${caloriesInMeal.round().toString()} Cal"),
                  SizedBox(width: 10.w),
                  TextButton(
                    onPressed: () {
                      handleNavigation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY,
                      foregroundColor: Colors.white,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size(5.w, 5.h),
                      padding: EdgeInsets.all(4.sp),
                    ),
                    child: Icon(Icons.add, size: 20.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (widget.meal.foods.isEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: CONT_BACKGROUND,
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 90.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.bowlRice, color: Colors.grey, size: 20.w),
                  SizedBox(height: 10.w),
                  Text(
                    "Track you meals for ${widget.meal.mealName}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color.fromARGB(255, 124, 124, 124),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                color: CONT_BACKGROUND,
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...widget.meal.foods.map(
                    (food) => Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              handleFoodClick(food);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: BORDER_SECONDARY,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0.r),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              food.name,
                                              style: TextStyle(fontSize: 15.sp),
                                            ),
                                          ),
                                          Text(
                                            "${food.quantity.value.round().toString()} ${food.quantity.unit}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                255,
                                                109,
                                                109,
                                                109,
                                              ),
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 80.w,
                                          child: Text(
                                            "${food.macros.calories.round().toString()} Cal",
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        SizedBox(width: 15.w),
                                        GestureDetector(
                                          onTap: () {
                                            removeFoodFromMeal(food);
                                          },
                                          child: Icon(
                                            FontAwesomeIcons.xmark,
                                            color: Colors.grey,
                                            size: 15.w,
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
                        // SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  handleNavigation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MealTrackerPage(meal: widget.meal, day: widget.day),
      ),
    );
    if (!mounted) return;
    setState(() {
      setCalories(true);
    });
  }

  removeFoodFromMeal(Food food) {
    setState(() {
      widget.meal.foods = widget.meal.foods.where((e) => e != food).toList();
      dayService.updateDayData(widget.day);
      setCalories(true);
    });
  }

  setCalories(bool emit) {
    caloriesInMeal = 0;
    for (var food in widget.meal.foods) {
      caloriesInMeal += food.macros.calories;
    }
    if (emit) {
      widget.onMealUpdated(null);
    }
  }

  handleFoodClick(Food food) async {
    await Future.delayed(Duration(milliseconds: 150));
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEntryPage(food: food, isCreateMode: false),
      ),
    );
    dayService.updateDayData(widget.day);
    setCalories(true);
    setState(() {});
  }
}
