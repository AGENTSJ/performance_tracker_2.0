import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/src/pages/AddFood.page.dart';
import 'package:performance_tracker/src/components/foodDescriptionPopUp.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class MealTrackerPage extends StatefulWidget {
  final Meal meal;
  final Day? day;
  const MealTrackerPage({super.key, required this.meal,required this.day});
  @override
  State<MealTrackerPage> createState() => _MealTrackerState();
}

class _MealTrackerState extends State<MealTrackerPage> {
  var dayService = locator<DayService>();
  TextEditingController foodNameControl = TextEditingController();
  var inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: PRIMARY, width: 1),
  );
  var foodListStyle = ElevatedButton.styleFrom(
    backgroundColor: BACKGROUND,
    foregroundColor: Colors.black,
    alignment: Alignment.centerLeft,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    minimumSize: Size(double.infinity, 20),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    elevation: 0,
  );
  final foodService = locator<FoodService>();
  final ai = locator<AiService>();
  List<Food> foods = [];
  List<Food> searchfoods = [];
  var showSearchRes = false;
  var showSuggested = true;
  _MealTrackerState() {
    foods = foodService.suggestFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.mealName, style: TextStyle(fontSize: 18)),
        backgroundColor: BACKGROUND,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Food name',
                focusedBorder: inputBorder,
                border: inputBorder,
                enabledBorder: inputBorder,
              ),
              controller: foodNameControl,
              onChanged: (str) {
                handleSearchChange(str);
              },
            ),
            if (showSearchRes) ...[
              // search
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Search results'),
                  IconButton(
                    onPressed: handleSearchClose,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                flex: 4,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: searchfoods.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ElevatedButton(
                      onPressed: () {
                        showAddFoodModal(searchfoods[index]);
                      },
                      style: foodListStyle,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Text('${searchfoods[index].name}'),
                      ),
                    );
                  },
                ),
              ),
              Visibility(
                visible: searchfoods.isEmpty,
                child: Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 40),
                        ),
                        child: Text('Custom'),
                      ),
                      SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () {handleAICustomFood();},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 40),
                        ),
                        child: Text('AI Create'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Column(
                // suggested
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Suggested'),
                      if (showSuggested) ...[
                        IconButton(
                          onPressed: () {
                            setState(() {
                              this.showSuggested = false;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ] else ...[
                        IconButton(
                          onPressed: () {
                            setState(() {
                              this.showSuggested = true;
                            });
                          },
                          icon: const Icon(Icons.visibility),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 5),
                  Visibility(
                    visible: showSuggested,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: foods.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ElevatedButton(
                              onPressed: () {
                                showAddFoodModal(foods[index]);
                              },
                              style: foodListStyle,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 5.0,
                                  bottom: 5.0,
                                ),
                                child: Text('${this.foods[index].name}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                // selected
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Selected'),
                    ],
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.meal.foods.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ElevatedButton(
                            onPressed: () {
                              showAddFoodModalUpdateMode(widget.meal.foods[index]);
                            },
                            style: foodListStyle,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: Text('${widget.meal.foods[index].name}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    foodNameControl.dispose();
    super.dispose();
  }

  handleSearchClose() {
    setState(() {
      showSearchRes = false;
    });
  }

  handleSearchChange(String str) {
    setState(() {
      showSearchRes = foodNameControl.text.isNotEmpty;
      if (showSearchRes) {
        searchfoods = foodService.searchFood(str);
      }
    });
  }

  showAddFoodModal(Food food) async {
    var newFood = food.clone();
    var returnedFood = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFoodModal(food: newFood,isCreateMode: true,)),
    );
    setState(() {
      if(returnedFood!=null)
      {
        widget.meal.foods.add(returnedFood);
        if(widget.day!=null)
        {
          dayService.updateDayData(widget.day!);
        }
      }
      foodNameControl.text = '';
      showSearchRes = false;
      searchfoods = [];
    });
  }

  showAddFoodModalUpdateMode(Food food) async
  {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFoodModal(food: food,isCreateMode: false,)),
    );
    dayService.updateDayData(widget.day!);
    setState(() {
    });
  }

  handleAICustomFood() async
  {
    if(foodNameControl.text.isNotEmpty)
    {
      var returnedFood = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => FoodDescriptionPopUp(foodName: foodNameControl.text,)
      );
      if(returnedFood!=null)
      {
        setState(() {        
          widget.meal.foods.add(returnedFood);
          dayService.updateDayData(widget.day!);
          foodNameControl.text = '';
          showSearchRes = false;
          searchfoods = [];
        });
      }
    }
  }
}