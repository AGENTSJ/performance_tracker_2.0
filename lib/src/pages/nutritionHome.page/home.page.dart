import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/comments.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
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
        title: Row(
          children: [
            Text(
              dayMarker,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                color: TEXT_PRIMARY,
              ),
            ),
            TextButton(
              onPressed: () {
                // toggleDateSelector();
                handleDatePickerEnable();
              },
              onLongPress: () async {
                handleDatePickerEnable();
              },
              child: Icon(Icons.arrow_drop_down, size: 30, color: TEXT_PRIMARY),
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
                      padding: const EdgeInsets.all(14.0),
                      child: ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        children: [
                          // Greetings
                          GreetingsWidget(
                            day: currentDay,
                          ),
                          SizedBox(height: 20),
                          // Total calories
                          Container(
                            decoration: BoxDecoration(
                              color: SURFACE2,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 110),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 8,
                                bottom: 8,
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
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                      fontSize: 16,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  IconButton(
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
                          SizedBox(height: 20),
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
                  Positioned(
                    child: Column(
                      children: [
                        // AnimatedContainer(
                        //   duration: Duration(milliseconds: 250),
                        //   curve: Curves.easeInOut,
                        //   height: showDateSelector ? 66 : 0,
                        //   width: double.infinity,
                        //   child: SingleChildScrollView(
                        //     child: DateSelector(
                        //       selectedDate: currentDay!.dayTime,
                        //       onDateChanged: (value) {
                        //         handleDateChange(value);
                        //       },
                        //     ),
                        //   ),
                        // ),
                        // if (showDateSelector)
                        //   Expanded(
                        //     child: GestureDetector(
                        //       onTap: () {
                        //         toggleDateSelector();
                        //       },
                        //       child: Container(color: Colors.transparent),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(child: SpinKitSpinningLines(color: PRIMARY)),
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
