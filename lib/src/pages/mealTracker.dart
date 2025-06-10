import 'package:flutter/material.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class MealTrackerPage extends StatefulWidget {
  const MealTrackerPage({super.key});
  @override
  State<MealTrackerPage> createState() => _MealTrackerState();
}

class _MealTrackerState extends State<MealTrackerPage> {
  TextEditingController foodNameControl = TextEditingController();
  var inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: PRIMARY, width: 1),
  );
  var foodService = FoodService();
  var foods;
  var showSearchRes = true;
  var showSuggested = true;
  _MealTrackerState() {
    this.foods = foodService.getFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: PRIMARY),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
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
                    onChanged: (str) {},
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Visibility(
                          visible: showSearchRes,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Search results'),
                                  IconButton(
                                    onPressed: () {
                                      this.handleSearchClose();
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              ...foods.map(
                                (food) => Padding(
                                  padding: EdgeInsetsGeometry.only(
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Text(food, style: TextStyle()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column( // suggested 
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
                            SizedBox(height: 20),
                            Visibility(
                              visible: showSuggested,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...foods.map(
                                    (food) => Padding(
                                      padding: EdgeInsetsGeometry.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      child: Text(food, style: TextStyle()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
      this.showSearchRes = false;
    });
  }
}
