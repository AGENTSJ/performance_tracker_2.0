import 'package:flutter/material.dart';
import 'package:performance_tracker/src/components/bottombar.dart';
import 'package:performance_tracker/src/components/mealContainer.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: PRIMARY),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: AppBar(
            backgroundColor: PRIMARY,
            shape: ContinuousRectangleBorder(),
          ),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            MealContainer(mealName: 'Break Fast'),
            MealContainer(mealName: 'Lunch'),
            MealContainer(mealName: 'Dinner'),
          ],
        ),
        bottomNavigationBar: BottomBar()
      ),
      
    );
  }
}