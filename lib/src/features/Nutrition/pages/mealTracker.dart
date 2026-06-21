import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/src/features/Nutrition/pages/foodEntry.page.dart';
import 'package:performance_tracker/src/features/Nutrition/widgets/foodDescriptionPopUp.dart';
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
    borderRadius: BorderRadius.circular(10.r),
    borderSide: BorderSide(color: PRIMARY, width: 1.w),
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
      suggestedFoods = suggestedFoods
          .where((element) => !_isPresentInSelected(element))
          .toList();
      setState(() {});
    });
  }

  bool _isPresentInSelected(Food food) {
    for (var selectedFood in widget.meal.foods) {
      if (selectedFood.name == food.name) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: Text(widget.meal.mealName, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: BACKGROUND,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(18.0.w),
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
                            size: 14.w,
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
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search results',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TEXT_SECONDARY,
                      ),
                    ),
                    IconButton(
                      onPressed: handleSearchClose,
                      icon: Icon(
                        Icons.close,
                        color: TEXT_SECONDARY,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: SURFACE,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      if (fetching) ...[
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40.w,
                                height: 40.h,
                                child: SpinKitSpinningLines(
                                  size: 40.w,
                                  color: PRIMARY,
                                ),
                              ),
                              SizedBox(width: 30.w),
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
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: BORDER_PRIMARY),
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0.w,
                                    vertical: 14.h,
                                  ),
                                  child: Row(children: [Text(food.name)]),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                if (suggestedFoods.isNotEmpty)
                  Column(
                    // suggested
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Suggested',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: TEXT_SECONDARY,
                            ),
                          ),
                          if (showSuggested) ...[
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showSuggested = false;
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: TEXT_SECONDARY,
                                size: 18.sp,
                              ),
                            ),
                          ] else ...[
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showSuggested = true;
                                });
                              },
                              icon: Icon(Icons.visibility, size: 18.w),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Visibility(
                        visible: showSuggested && suggestedFoods.isNotEmpty,
                        child: Container(
                          decoration: BoxDecoration(
                            color: SURFACE2,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: [
                              ...suggestedFoods.map(
                                (food) => Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      handleSelectSuggestedFood(food);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: SURFACE2,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: BORDER_PRIMARY,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.0.w,
                                          vertical: 14.h,
                                        ),
                                        child: Row(children: [Text(food.name)]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.only(top: 8.0.h, bottom: 8.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: TEXT_SECONDARY,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.h),
                Container(
                  decoration: BoxDecoration(
                    color: SURFACE,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
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
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: BORDER_PRIMARY),
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0.w,
                                    vertical: 14.h,
                                  ),
                                  child: Row(children: [Text(food.name)]),
                                ),
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
              ],
            ],
          ),
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

  bool fetching = false;
  handleSearchChange(String str) async {
    showSearchRes = foodNameControl.text.isNotEmpty;
    searchfoods = [];
    fetching = true;
    setState(() {});
    if (foodNameControl.text.isEmpty) {
      return;
    }
    searchfoods = await foodService.searchFood(str);
    fetching = false;
    setState(() {});
  }

  showAddFoodModal(Food food) async {
    var newFood = food.clone();
    var returnedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEntryPage(food: newFood, isCreateMode: true),
      ),
    );
    if (returnedFood != null) {
      widget.meal.foods.add(returnedFood);
      dayService.updateDayData(widget.day);
    }
    foodNameControl.text = '';
    showSearchRes = false;
    searchfoods = [];
    setState(() {});
  }

  handleSelectSuggestedFood(Food food) {
    var newFood = food.clone();
    widget.meal.foods.add(newFood);
    suggestedFoods.remove(food);
    dayService.updateDayData(widget.day);
    setState(() {});
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
        barrierDismissible: true,
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
      height: 200.h,
      decoration: BoxDecoration(
        color: BACKGROUND,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100.h, width: 100.w, child: empty),
            SizedBox(height: 10.h),
            Text(insideText, style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
