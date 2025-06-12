import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class AddFoodModal extends StatefulWidget {
  final Food food;
  const AddFoodModal({super.key, required this.food});
  @override
  State<StatefulWidget> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<AddFoodModal> {
  var caloriesController = TextEditingController();
  @override
  void initState() {
    super.initState();
    this.caloriesController.text = widget.food.baseUnit.value.round().toString();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: BACKGROUND),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // measure container
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/food-template.png'),
                                  fit: BoxFit.fitWidth,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              bottom: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.food.name ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text('Measure'),
                                    SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: Center(
                                        child: Text(
                                          widget.food.baseUnit.unit,
                                          style: TextStyle(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Quantity'),
                                    Container(
                                      width: 50,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            constraints: BoxConstraints(
                                              maxHeight: 40,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 10,
                                                ),
                                          ),
                                          controller: caloriesController,
                                          onChanged: (str){handleQuantityChange(str);},
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // macro
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text('Macro nutrients breakdown'),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Protein'),
                            Text(widget.food.macros.protein.round().toString()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Carbohydrate'),
                            Text(
                              widget.food.macros.carbohydrate
                                  .round()
                                  .toString(),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fat'),
                            Text(widget.food.macros.fat.round().toString()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fiber'),
                            Text(widget.food.macros.fiber.round().toString()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Calories'),
                            Text(
                              widget.food.macros.calories.round().toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('Micro nutrients breakdown'),
            SizedBox(height: 10),
            // micro
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(bottom: 30, left: 8, right: 8),
                child: ListView(
                  children: widget.food.micros.microMap.entries.map((entry) {
                    final microNutrient = entry.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          microNutrient != null
                              ? '${microNutrient.value} ${microNutrient.unit}'
                              : '-',
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  handleQuantityChange(String str)
  {
    setState(() {
      var baseQuant = widget.food.baseUnit.value;
      double newQuant = double.parse( str.isEmpty ? '0' : str);
      if(newQuant<0)
      {
        // caloriesController.text = '0';
        newQuant = 0;
      }
      if(MAX_FOOD_QUANTITY_ALLOWED<newQuant)
      {
        // caloriesController.text = MAX_FOOD_QUANTITY_ALLOWED.toString();
        newQuant = MAX_FOOD_QUANTITY_ALLOWED;
      }
      widget.food.macros.calories = (widget.food.macros.calories/baseQuant)*newQuant;
      widget.food.macros.fat = (widget.food.macros.fat/baseQuant)*newQuant;
      widget.food.macros.protein = (widget.food.macros.protein/baseQuant)*newQuant;
      widget.food.macros.carbohydrate = (widget.food.macros.carbohydrate/baseQuant)*newQuant;
      widget.food.macros.fiber = (widget.food.macros.fiber/baseQuant)*newQuant;
      print(widget.food.macros.fat);
    });
  }

  getStandardFood(Food food)
  {
    
  }
}
