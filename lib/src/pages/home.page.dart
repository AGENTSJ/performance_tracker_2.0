import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/src/components/bottomBar.dart';
import 'package:performance_tracker/src/components/dateSelector.dart';
import 'package:performance_tracker/src/components/mealContainer.dart';
import 'package:performance_tracker/src/constants.ui.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dayService = locator<DayService>();
  late Day? currentDay = null;
  String dayMarker = '';
  bool showDateSelector = false;

  @override
  void initState() {
    super.initState();
    dayService.getDayDataByDate(DateTime.now()).then(
      (day) => {
        setState(() {
          currentDay = day;
          _setCurrentDayMarker();
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: PRIMARY,
        scaffoldBackgroundColor: BACKGROUND,
      ),
      home: Scaffold(
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
                child: Icon(Icons.arrow_drop_down, size: 19),
              ),
            ],
          ),
          backgroundColor: BACKGROUND,
          shape: ContinuousRectangleBorder(),
        ),
        body: Stack(
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              children: [
                if (currentDay != null)
                  ...currentDay!.meals!.map(
                    (meal) => MealContainer(meal: meal, day: currentDay!),
                  ),
              ],
            ),
            if (showDateSelector) ...[Positioned(child: DateSelector(selectedDate: currentDay!.dayTime,onDateChanged:(value){handleDateChange(value);},))],
          ],
        ),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }

  _setCurrentDayMarker()
  {
    var currentDateMarker = dayService.getDateString(currentDay!.dayTime);
    if(dayService.getDateString(DateTime.now())==currentDateMarker)
    {
      dayMarker = 'Today';
    }
    else
    {
      dayMarker = currentDateMarker;
    }
  }
  toggleDateSelector()
  {
    setState(() {
      showDateSelector = !showDateSelector;
    });
  }
  handleDateChange(DateTime value)async
  {
    this.currentDay = await dayService.getDayDataByDate(value);
    setState(() {
      this.showDateSelector = false;
      _setCurrentDayMarker();
    });
  }
}
