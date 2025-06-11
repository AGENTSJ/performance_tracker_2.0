import 'package:flutter/material.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class AddFoodModal extends StatefulWidget {
  final Food food;
  const AddFoodModal({super.key, required this.food});
  @override
  State<StatefulWidget> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<AddFoodModal> {
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
              flex: 2,
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
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text('Measure'),
                                      Text(widget.food.baseUnit.unit),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text('Quantity'),
                                      Text(
                                        widget.food.baseUnit.value.toString(),
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
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Protein'),
                          Text(widget.food.macros.protein.toString()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Carbohydrate'),
                          Text(widget.food.macros.carbohydrate.toString()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fat'),
                          Text(widget.food.macros.fat.toString()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fiber'),
                          Text(widget.food.macros.fiber.toString()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('Micro nutrients breakdown'),
            SizedBox(height: 10),
            // micro
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
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
}
