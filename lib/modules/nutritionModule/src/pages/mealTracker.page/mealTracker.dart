import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/modules/nutritionModule/models/day.model.dart';
import 'package:performance_tracker/modules/nutritionModule/models/food.model.dart';
import 'package:performance_tracker/modules/sharedModule/services/ai.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/day.service.dart';
import 'package:performance_tracker/modules/nutritionModule/services/foods.service.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/foodEntry.page/foodEntry.page.dart';
import 'package:performance_tracker/modules/nutritionModule/src/components/foodDescriptionPopUp.dart';
import 'package:performance_tracker/constants.ui.dart';

class MealTrackerPage extends StatefulWidget {
  final Meal meal;
  final Day day;
  const MealTrackerPage({super.key, required this.meal, required this.day});
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
  final foodService = locator<FoodService>();
  final ai = locator<AiService>();
  List<Food> suggestedFoods = [];
  List<Food> searchfoods = [];
  var showSearchRes = false;
  var showSuggested = true;

  @override
  void initState() {
    super.initState();
    foodService.suggestFoods(widget.meal, widget.day).then((suggestions) {
      suggestedFoods = suggestions;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: Text(widget.meal.mealName, style: TextStyle(fontSize: 18)),
        backgroundColor: BACKGROUND,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Food name',
                focusedBorder: inputBorder,
                border: inputBorder,
                enabledBorder: inputBorder,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Tooltip(
                        message: 'Let AI help you create a custom food entry',
                        child: Icon(
                          FontAwesomeIcons.wandSparkles,
                          color: Colors.amber[400],
                          size: 14,
                        ),
                      ),
                      onPressed: () {
                        handleAICustomFood();
                      },
                    ),
                  ],
                ),
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
                  Text(
                    'Search results',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: handleSearchClose,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    if (fetching) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 30),
                            Text(
                              'Fetching....',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ] else if (searchfoods.isEmpty) ...[
                      EmptyResultsWidget(
                        insideText: "No food with such name was found..",
                      ),
                    ] else
                      ...searchfoods.map(
                        (food) => Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showAddFoodModal(food);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(children: [Text('${food.name}')]),
                            ),
                          ),
                        ),
                      ),
                  ],
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
                      Text(
                        'Suggested',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (showSuggested) ...[
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showSuggested = false;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ] else ...[
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showSuggested = true;
                            });
                          },
                          icon: const Icon(Icons.visibility, size: 18),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 5),
                  Visibility(
                    visible: showSuggested,
                    child: SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (suggestedFoods.isEmpty) ...[
                              EmptyResultsWidget(
                                insideText: "No suggestions found",
                              ),
                            ] else
                              ...suggestedFoods.map(
                                (food) => Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      showAddFoodModal(food);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [Text('${food.name}')],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.meal.foods.isNotEmpty)
                        ...widget.meal.foods.map(
                          (food) => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                showAddFoodModalUpdateMode(food);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [Text('${food.name}')]),
                              ),
                            ),
                          ),
                        ),
                      if (widget.meal.foods.isEmpty) ...[
                        EmptyResultsWidget(insideText: "No foods are selected"),
                      ],
                    ],
                  ),
                ),
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

  Timer? fetchFoodsData;
  bool fetching = false;
  handleSearchChange(String str) async {
    showSearchRes = foodNameControl.text.isNotEmpty;
    searchfoods = [];
    fetching = true;
    setState(() {});
    if (fetchFoodsData == null) {
      fetchFoodsData = Timer(Duration(milliseconds: 1000), () async {
        if (foodNameControl.text.isEmpty) {
          return;
        }
        searchfoods = await foodService.searchFood(str);
        fetchFoodsData = null;
        fetching = false;
        setState(() {});
      });
    } else {
      fetchFoodsData!.cancel();
      fetchFoodsData = Timer(Duration(milliseconds: 1000), () async {
        if (foodNameControl.text.isEmpty) {
          return;
        }
        searchfoods = await foodService.searchFood(str);
        fetchFoodsData = null;
        fetching = false;
        setState(() {});
      });
    }
  }

  showAddFoodModal(Food food) async {
    var newFood = food.clone();
    var returnedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEntryPage(food: newFood, isCreateMode: true),
      ),
    );
    setState(() {
      if (returnedFood != null) {
        widget.meal.foods.add(returnedFood);
        dayService.updateDayData(widget.day);
      }
      foodNameControl.text = '';
      showSearchRes = false;
      searchfoods = [];
    });
  }

  showAddFoodModalUpdateMode(Food food) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEntryPage(food: food, isCreateMode: false),
      ),
    );
    dayService.updateDayData(widget.day);
    setState(() {});
  }

  handleAICustomFood() async {
    if (foodNameControl.text.isNotEmpty) {
      var returnedFood = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            FoodDescriptionPopUp(foodName: foodNameControl.text),
      );
      if (returnedFood != null) {
        setState(() {
          widget.meal.foods.add(returnedFood);
          dayService.updateDayData(widget.day);
          foodNameControl.text = '';
          showSearchRes = false;
          searchfoods = [];
        });
      }
    }
  }
}

class EmptyResultsWidget extends StatelessWidget {
  final String insideText;
  const EmptyResultsWidget({super.key, required this.insideText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_neutral, size: 30),
            SizedBox(height: 10),
            Text(insideText, style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
