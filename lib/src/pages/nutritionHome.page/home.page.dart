import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/comments.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
import 'package:performance_tracker/src/pages/loading.page/loading.page.dart';
import 'package:performance_tracker/src/pages/nutritionHome.page/widgets/mealContainer.dart';
import 'package:performance_tracker/src/pages/nutritionAnalysis.page/nutritionAnalysis.page.dart';
import 'package:performance_tracker/src/pages/nutritionHome.page/widgets/greetingWidgets.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NutritionModule extends StatefulWidget {
  const NutritionModule({super.key});
  @override
  State<StatefulWidget> createState() => NutritionModuleState();
}

class NutritionModuleState extends State<NutritionModule> {
  final dayService = locator<DayService>();
  final commentService = locator<CommentsService>();
  final avatarService = locator<AvatarService>();
  final goalService = locator<UserGoalsService>();
  Day? currentDay;
  late MacroNutrients daysMacro;
  String dayMarker = '';
  bool showDateSelector = false;
  bool showWholeGreetings = false;
  bool isHomePageLoading = false;
  @override
  void initState() {
    super.initState();
    _setHomePage();
  }

  _setHomePage() async {
    isHomePageLoading = true;
    refreshState();
    var day = await dayService.getDayDataByDate(DateTime.now());
    currentDay = day;
    _setCurrentDayMarker();
    setCaloriesInDay();
    isHomePageLoading = false;
    await Future.delayed(Duration(milliseconds: WAITING_PERIOD_PAGE_SWITCH_MS));
    refreshState();
  }

  void refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  handleGreetingContainerChange() {
    showWholeGreetings = !showWholeGreetings;
    refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        scrolledUnderElevation:0,
        title: Row(
          children: [
            Text(
              dayMarker,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w500,
                color: TEXT_PRIMARY,
              ),
            ),
            TextButton(
              onPressed: () {
                handleDatePickerEnable();
              },
              onLongPress: () async {
                handleDatePickerEnable();
              },
              child: Icon(Icons.arrow_drop_down, size: 30.w, color: TEXT_PRIMARY),
            ),
          ],
        ),
        backgroundColor: BACKGROUND,
        shape: ContinuousRectangleBorder(),
      ),
      body: !isHomePageLoading
          ? RefreshIndicator(
              onRefresh: () async {
                await _setHomePage();
              },
              child: Stack(
                children: [
                  if (currentDay != null) ...[
                    Padding(
                      padding: EdgeInsets.all(14.0.w),
                      child: ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        children: [
                          // Greetings
                          GreetingsWidget(
                            day: currentDay,
                          ),
                          SizedBox(height: 20.h),
                          // Total calories
                          Container(
                            decoration: BoxDecoration(
                              color: SURFACE2,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.r),
                              ),
                            ),
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 110.h),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 20.w,
                                right: 20.w,
                                top: 8.h,
                                bottom: 8.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: PRIMARY,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0.w),
                                      child: Icon(
                                        Icons.restaurant_menu_sharp,
                                        color: PRIMARY,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${daysMacro.calories.round()} of ${currentDay?.goalForToday?.calorieLimit.round()} Cal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  IconButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SURFACE
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NutritionAnalysisPage(
                                                day: currentDay!,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.bar_chart_outlined,
                                      color: PRIMARY,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ...currentDay!.meals!.map(
                            (meal) => MealContainer(
                              key: ValueKey(
                                "$dayMarker ${meal.calories} ${meal.mealName}",
                              ),
                              meal: meal,
                              day: currentDay!,
                              onMealUpdated: (value) {
                                setCaloriesInDay();
                                refreshState();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            )
          : LoadingPage(),
    );
  }

  handleDatePickerEnable() async {
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDay!.dayTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    if (pickedDate != null) {
      handleDateChange(pickedDate);
    }
  }

  _setCurrentDayMarker() {
    var currentDateMarker = dayService.getDateString(currentDay!.dayTime);
    if (dayService.getDateString(DateTime.now()) == currentDateMarker) {
      dayMarker = 'Today';
    } else {
      dayMarker = currentDateMarker;
    }
  }

  toggleDateSelector() {
    showDateSelector = !showDateSelector;
    refreshState();
  }

  handleDateChange(DateTime value) async {
    currentDay = await dayService.getDayDataByDate(value);
    _setCurrentDayMarker();
    setCaloriesInDay();
    showDateSelector = false;
    refreshState();
  }

  setCaloriesInDay() {
    daysMacro = dayService.getDaysCalories(currentDay!);
  }
}
