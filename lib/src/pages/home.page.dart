import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/src/components/bottomBar.dart';
import 'package:performance_tracker/src/components/mealContainer.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class HomePage extends StatefulWidget {
  
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState()=>HomePageState();

}

class HomePageState extends State<HomePage>
{
  final dayService  = locator<DayService>();
  late Day? today;

  @override
  void initState() {
    super.initState();
    dayService.getCurrentDayData().then((day)=>{
      setState(() {
        today = day;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: PRIMARY,scaffoldBackgroundColor: BACKGROUND),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Today',style: TextStyle(fontSize: 19 ,fontWeight: FontWeight.w500),),
          backgroundColor: BACKGROUND,
          shape: ContinuousRectangleBorder(),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            if(today!=null)...today!.meals!.map((meal)=>MealContainer(meal: meal,day: today!,))
          ],
        ),
        bottomNavigationBar: BottomBar()
      ),
    );
  }
}