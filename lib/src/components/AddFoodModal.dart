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
  Food? standard;
  @override
  void initState() {
    super.initState();
    this.caloriesController.text = widget.food.quantity.value
        .round()
        .toString();
    this.standard = this.getStandardFood(widget.food);
    print(this.standard!.quantity.value);
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
                                          widget.food.quantity.unit,
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
                                      width: 80,
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
                                          onChanged: (str) {
                                            handleQuantityChange(str);
                                          },
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Macro nutrients breakdown',textAlign:TextAlign.left,style: TextStyle(fontWeight: FontWeight.w600),),
                  ),
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
            Align(alignment: Alignment.centerLeft,child: Text('Micro nutrients breakdown',style: TextStyle(fontWeight: FontWeight.w600),)),
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
            Container(
              child: ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY,
                  minimumSize: Size(double.infinity, 50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))
                ),
                child: Text('Add Food'),
              ),
            )
          ],
        ),
      ),
    );
  }

  handleQuantityChange(String str) {
    setState(() {
      double newQuant = double.parse(str.isEmpty ? '0' : str);
      if (newQuant < 0) {
        caloriesController.text = '0';
        newQuant = 0;
      }
      if (MAX_FOOD_QUANTITY_ALLOWED < newQuant) {
        caloriesController.text = MAX_FOOD_QUANTITY_ALLOWED.toString();
        newQuant = MAX_FOOD_QUANTITY_ALLOWED;
      }
      updateFood(newQuant);
    });
  }

  getStandardFood(Food food) {
    var baseQuant = food.quantity.value;

    var newFood = Food(
      macros: MacroNutrients(
        (food.macros.protein / baseQuant),
        (food.macros.carbohydrate / baseQuant),
        (food.macros.fat / baseQuant),
        (food.macros.fiber / baseQuant),
        (food.macros.calories / baseQuant),
      ),
      micros: MicroNutrients(
        vitaminA: food.micros.vitaminA != null
            ? MeasuredUnit(
                value: (food.micros.vitaminA!.value / baseQuant),
                unit: food.micros.vitaminA!.unit,
              )
            : null,
        vitaminC: food.micros.vitaminC != null
            ? MeasuredUnit(
                value: (food.micros.vitaminC!.value / baseQuant),
                unit: food.micros.vitaminC!.unit,
              )
            : null,
        vitaminD: food.micros.vitaminD != null
            ? MeasuredUnit(
                value: (food.micros.vitaminD!.value / baseQuant),
                unit: food.micros.vitaminD!.unit,
              )
            : null,
        vitaminE: food.micros.vitaminE != null
            ? MeasuredUnit(
                value: (food.micros.vitaminE!.value / baseQuant),
                unit: food.micros.vitaminE!.unit,
              )
            : null,
        vitaminK: food.micros.vitaminK != null
            ? MeasuredUnit(
                value: (food.micros.vitaminK!.value / baseQuant),
                unit: food.micros.vitaminK!.unit,
              )
            : null,
        thiamin: food.micros.thiamin != null
            ? MeasuredUnit(
                value: (food.micros.thiamin!.value / baseQuant),
                unit: food.micros.thiamin!.unit,
              )
            : null,
        riboflavin: food.micros.riboflavin != null
            ? MeasuredUnit(
                value: (food.micros.riboflavin!.value / baseQuant),
                unit: food.micros.riboflavin!.unit,
              )
            : null,
        niacin: food.micros.niacin != null
            ? MeasuredUnit(
                value: (food.micros.niacin!.value / baseQuant),
                unit: food.micros.niacin!.unit,
              )
            : null,
        vitaminB6: food.micros.vitaminB6 != null
            ? MeasuredUnit(
                value: (food.micros.vitaminB6!.value / baseQuant),
                unit: food.micros.vitaminB6!.unit,
              )
            : null,
        folate: food.micros.folate != null
            ? MeasuredUnit(
                value: (food.micros.folate!.value / baseQuant),
                unit: food.micros.folate!.unit,
              )
            : null,
        vitaminB12: food.micros.vitaminB12 != null
            ? MeasuredUnit(
                value: (food.micros.vitaminB12!.value / baseQuant),
                unit: food.micros.vitaminB12!.unit,
              )
            : null,
        pantothenicAcid: food.micros.pantothenicAcid != null
            ? MeasuredUnit(
                value: (food.micros.pantothenicAcid!.value / baseQuant),
                unit: food.micros.pantothenicAcid!.unit,
              )
            : null,
      ),
      quantity: MeasuredUnit(
        value: (food.quantity.value / baseQuant),
        unit: food.quantity.unit,
      ),
    );

    return newFood;
  }

  updateFood(double newQuant) {
    widget.food.macros.protein = (standard!.macros.protein * newQuant);
    widget.food.macros.carbohydrate =
        (standard!.macros.carbohydrate * newQuant);
    widget.food.macros.fat = (standard!.macros.fat * newQuant);
    widget.food.macros.fiber = (standard!.macros.fiber * newQuant);
    widget.food.macros.calories = (standard!.macros.calories * newQuant);

    // Update micros directly
    void updateMicro(
      MeasuredUnit? target,
      MeasuredUnit? std,
      String unit,
      double newQuant,
    ) {
      if (target != null && std != null) {
        // target.value = std.value * newQuant;
        target.value = double.parse((std.value * newQuant).toStringAsFixed(2));
        ;
        target.unit = unit;
      }
    }

    updateMicro(
      widget.food.micros.vitaminA,
      standard!.micros.vitaminA,
      widget.food.micros.vitaminA?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.vitaminC,
      standard!.micros.vitaminC,
      widget.food.micros.vitaminC?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.vitaminD,
      standard!.micros.vitaminD,
      widget.food.micros.vitaminD?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.vitaminE,
      standard!.micros.vitaminE,
      widget.food.micros.vitaminE?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.vitaminK,
      standard!.micros.vitaminK,
      widget.food.micros.vitaminK?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.thiamin,
      standard!.micros.thiamin,
      widget.food.micros.thiamin?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.riboflavin,
      standard!.micros.riboflavin,
      widget.food.micros.riboflavin?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.niacin,
      standard!.micros.niacin,
      widget.food.micros.niacin?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.vitaminB6,
      standard!.micros.vitaminB6,
      widget.food.micros.vitaminB6?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.folate,
      standard!.micros.folate,
      widget.food.micros.folate?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.vitaminB12,
      standard!.micros.vitaminB12,
      widget.food.micros.vitaminB12?.unit ?? '',
      newQuant,
    );
    updateMicro(
      widget.food.micros.pantothenicAcid,
      standard!.micros.pantothenicAcid,
      widget.food.micros.pantothenicAcid?.unit ?? '',
      newQuant,
    );

    // Update baseUnit directly
    widget.food.quantity.value = newQuant;
  }
}
