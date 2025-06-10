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
  var showSearchRes = false;
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
            TextField(
              decoration: InputDecoration(
                hintText: 'Food name',
                focusedBorder: inputBorder,
                border: inputBorder,
                enabledBorder: inputBorder,
              ),
              controller: foodNameControl,
              onChanged: (str) {handleSearchChange(str);},
            ),
            if (showSearchRes) ...[
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Search results'),
                  IconButton(onPressed: handleSearchClose, icon: Icon(Icons.close))
                ],
              ),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: foods.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 5.0,bottom: 5.0),
                      child: Text('${foods[index]}'),
                    );
                  },
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...foods.map(
                            (food) => Padding(
                              padding: EdgeInsetsGeometry.only(top: 5, bottom: 5),
                              child: Text(food, style: TextStyle()),
                            ),
                          ),
                        ],
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
  handleSearchChange(String str)
  {
    setState(() { 
      showSearchRes = foodNameControl.text.isNotEmpty;
    });
  }
}
