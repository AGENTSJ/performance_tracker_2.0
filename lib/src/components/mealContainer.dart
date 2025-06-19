import 'package:flutter/material.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/src/constants.ui.dart';
import 'package:performance_tracker/src/pages/mealTracker.dart';

class MealContainer extends StatefulWidget {
  final Meal meal;
  final Day day;
  const MealContainer({super.key, required this.meal,required this.day});

  @override
  State<MealContainer> createState() => _MealContainerState();
}

class _MealContainerState extends State<MealContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.meal.mealName,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16),),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PRIMARY
                  ),
                  width: 25,
                  height: 25,
                ),
                Positioned( bottom:-8,left: -7,  child: IconButton(onPressed: (){handleNavigation();}, icon: Icon(Icons.add,color: const Color.fromARGB(255, 255, 255, 255),size: 20,)))
              ],
            )
            ],
        ),
        SizedBox(height: 20,),
        Container(
          decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(8))),
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 80),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                ...widget.meal.foods.map((food) => 
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[ 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 200, child: Text(food.name ?? '' ,style: TextStyle(fontSize: 15),)),
                            Text("${food.quantity.value.round().toString()} ${food.quantity.unit}" ,textAlign: TextAlign.start,style: TextStyle(color: const Color.fromARGB(255, 109, 109, 109),fontSize: 14),),
                          ],
                        ),
                        Text(food.macros.calories.round().toString())
                      ]
                    ),
                    SizedBox(height: 20,)
                  ],
                )
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  handleNavigation() async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>MealTrackerPage(meal: widget.meal,day: widget.day,)));
    if (!mounted) return;
    setState(() {
    });
  }
}
