import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/src/constants.ui.dart';
import 'package:performance_tracker/src/pages/AddFood.page.dart';
import 'package:performance_tracker/src/pages/mealTracker.dart';

class MealContainer extends StatefulWidget {
  final Meal meal;
  final Day day;
  final ValueChanged onMealUpdated;

  const MealContainer({super.key, required this.meal, required this.day,required this.onMealUpdated});

  @override
  State<MealContainer> createState() => _MealContainerState();
}

class _MealContainerState extends State<MealContainer> {
  late double caloriesInMeal = 0;
  var dayService = locator<DayService>();
  
  @override
  void initState() {
    super.initState();
    setCalories(false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.meal.mealName,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Row(
              children: [
                Text("${caloriesInMeal.round().toString()} Cal"),
                SizedBox(width: 10,),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PRIMARY,
                      ),
                      width: 25,
                      height: 25,
                    ),
                    Positioned(
                      bottom: -11,
                      left: -11,
                      child: IconButton(
                        onPressed: () {
                          handleNavigation();
                        },
                        icon: Icon(
                          Icons.add,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 80),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(widget.meal.foods.isEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Track you meals for ${widget.meal.mealName}",style: TextStyle(fontSize: 12 ,color: const Color.fromARGB(255, 124, 124, 124)),),
                      SizedBox(width: 10,),
                      Icon(Icons.fastfood ,color: Colors.grey,size: 20,)
                    ],
                  )
                ]
                else
                ...widget.meal.foods.map(
                  (food) => Column(
                    children: [
                      SingleChildScrollView(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              handleFoodClick(food);
                            },
                            splashColor: const Color.fromARGB(91, 188, 188, 188),
                            highlightColor: const Color.fromARGB(91, 188, 188, 188),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        food.name ?? '',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      "${food.quantity.value.round().toString()} ${food.quantity.unit}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          109,
                                          109,
                                          109,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 50, 
                                      child: Text("${food.macros.calories.round().toString()} Cal",textAlign: TextAlign.right,)
                                    ),
                                    SizedBox(width: 15,),
                                    GestureDetector(
                                      onTap: () {
                                        removeFoodFromMeal(food);
                                      },
                                      child: Icon(Icons.delete,color: Colors.grey, size: 20,)
                                    )
                                  ]
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  handleNavigation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MealTrackerPage(meal: widget.meal, day: widget.day),
      ),
    );
    if (!mounted) return;
    setState(() {
      setCalories(true);
    });
  }

  removeFoodFromMeal(Food food)
  {
    setState(() {
      widget.meal.foods = widget.meal.foods.where((e)=>e!=food).toList();
      dayService.updateDayData(widget.day);
      setCalories(true);
    });
  }

  setCalories(bool emit) {  
    caloriesInMeal = 0;
    for (var food in widget.meal.foods) {
      caloriesInMeal += food.macros.calories;
    }
    if(emit)
    {
      widget.onMealUpdated(null);
    }
  }

  handleFoodClick(Food food) async
  {
    await Future.delayed(Duration(milliseconds: 150));
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFoodModal(food: food,isCreateMode: false,)),
    );
    dayService.updateDayData(widget.day);
    setCalories(true);
    setState(() {
    });
  }
}
