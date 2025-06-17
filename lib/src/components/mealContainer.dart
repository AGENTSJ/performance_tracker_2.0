import 'package:flutter/material.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/src/pages/mealTracker.dart';

class MealContainer extends StatefulWidget {
  final Meal meal;
  const MealContainer({super.key, required this.meal});

  @override
  State<MealContainer> createState() => _MealContainerState();
}

class _MealContainerState extends State<MealContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(widget.meal.mealName),IconButton(
              onPressed: (){handleNavigation();}, icon: Icon(Icons.add))],
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(8))),
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 80),
            child: Column(
              children: [
                ...widget.meal.foods.map((food) => 
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[ 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food.name ?? ''),
                          Text("${food.quantity.value.round().toString()} ${food.quantity.unit}" ,textAlign: TextAlign.start,),
                        ],
                      ),
                      Text(food.macros.calories.toString())
                    ]
                  ),
                )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  handleNavigation() async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>MealTrackerPage(meal: widget.meal,)));
    setState(() {
      
    });
  }
}
