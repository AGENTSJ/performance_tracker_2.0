import 'package:flutter/material.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/src/components/bottombar.dart';
import 'package:performance_tracker/src/components/mealContainer.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class HomePage extends StatelessWidget {
  Day today = new Day();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: PRIMARY,scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243)),
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
            ...today.meals!.map((meal)=>MealContainer(meal: meal))
          ],
        ),
        bottomNavigationBar: BottomBar()
      ),
      
    );
  }
}