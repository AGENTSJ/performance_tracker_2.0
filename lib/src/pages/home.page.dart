import 'package:flutter/material.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/src/components/bottomBar.dart';
import 'package:performance_tracker/src/components/mealContainer.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class HomePage extends StatelessWidget {
  final Day today = Day();
  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: PRIMARY,scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243)),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: PRIMARY,
          shape: ContinuousRectangleBorder(),
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