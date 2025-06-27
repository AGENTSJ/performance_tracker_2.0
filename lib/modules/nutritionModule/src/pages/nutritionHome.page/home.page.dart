import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/modules/nutritionModule/models/day.model.dart';
import 'package:performance_tracker/modules/nutritionModule/models/food.model.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/comments.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/day.service.dart';
import 'package:performance_tracker/src/components/bottomBar.dart';
import 'package:performance_tracker/modules/nutritionModule/src/components/dateSelector.dart';
import 'package:performance_tracker/modules/nutritionModule/src/components/mealContainer.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/nutritionAnalysis.page/nutritionAnalysis.page.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/nutritionHome.page/widgets/greetingWidgets.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dayService = locator<DayService>();
  final commentService = locator<CommentsService>();
  final avatarService = locator<AvatarService>();
  late Day? currentDay = null;
  late MacroNutrients daysMacro;
  String dayMarker = '';
  bool showDateSelector = false;
  bool showWholeGreetings = false;
  double totalCalorieForToday = 2000;
  @override
  void initState() {
    print('nuti-home-init-ran');
    super.initState();
    dayService
        .getDayDataByDate(DateTime.now())
        .then(
          (day) => {
            setState(() {
              currentDay = day;
              _setCurrentDayMarker();
              setCaloriesInDay();
            }),
          },
        );
  }

  handleGreetingContainerChange() {
    this.showWholeGreetings = !showWholeGreetings;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                dayMarker,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
              ),
              TextButton(
                onPressed: () {
                  toggleDateSelector();
                },
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          backgroundColor: BACKGROUND,
          shape: ContinuousRectangleBorder(),
        ),
        body: Stack(
          children: [
            if (currentDay != null) ...[
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    // Greetings
                    GreetingsWidget(day: currentDay,key: ValueKey(daysMacro.calories),),
                    SizedBox(height: 20),
                    // Total calories
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: PRIMARY, width: 2),
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
                              "${daysMacro.calories.round()} of ${totalCalorieForToday.round()} Cal",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>NutritionAnalysisPage(day: currentDay!)));
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
                      (meal) => Padding(
                        key: ValueKey("$dayMarker ${meal.mealName}"),
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: MealContainer(
                          meal: meal,
                          day: currentDay!,
                          onMealUpdated: (value) {
                            setState(() {
                              setCaloriesInDay();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showDateSelector) ...[
              Positioned(
                child: DateSelector(
                  selectedDate: currentDay!.dayTime,
                  onDateChanged: (value) {
                    handleDateChange(value);
                  },
                ),
              ),
            ],
          ],
        ),
        bottomNavigationBar: !showDateSelector? BottomBar() :null,
      );
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
    setState(() {
      showDateSelector = !showDateSelector;
    });
  }

  handleDateChange(DateTime value) async {
    currentDay = await dayService.getDayDataByDate(value);
    setState(() {
      showDateSelector = false;
      _setCurrentDayMarker();
      setCaloriesInDay();
    });
  }

  setCaloriesInDay() {
    daysMacro = dayService.getDaysCalories(currentDay!);
  }
}

