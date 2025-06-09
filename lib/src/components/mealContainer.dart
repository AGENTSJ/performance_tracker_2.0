import 'package:flutter/material.dart';
import 'package:performance_tracker/models/food.model.dart';

class MealContainer extends StatefulWidget {
  final String mealName;
  const MealContainer({Key? key, required this.mealName}) : super(key: key);

  @override
  State<MealContainer> createState() => _MealContainerState();
}

class _MealContainerState extends State<MealContainer> {
  List<Food> foods = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Align(child: Text(widget.mealName), alignment: Alignment.centerLeft),
          ...foods.map((food) => Text(food.name ?? '')),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Add Food'),
                        content: Text('This is a pop-up modal!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the modal
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Show Modal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addFood(String name) {
    setState(() {
      foods.add(Food(name: name));
    });
  }
}
