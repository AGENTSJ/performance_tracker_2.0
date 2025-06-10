import 'package:flutter/material.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/src/pages/mealTracker.dart';

class MealContainer extends StatefulWidget {
  final Meal meal;
  const MealContainer({Key? key, required this.meal}) : super(key: key);

  @override
  State<MealContainer> createState() => _MealContainerState();
}

class _MealContainerState extends State<MealContainer> {
  List<Food> foods = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(widget.meal.mealName),IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>MealTrackerPage()));}, icon: Icon(Icons.add))],
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(8))),
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 80),
              child: Column(
                children: [
                  ...foods.map((food) => Text(food.name ?? '')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void addFood(String name) {
    setState(() {
      foods.add(Food(name: name));
    });
  }
}
