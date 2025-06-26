import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/modules/nutritionModule/constants.dart';
import 'package:performance_tracker/modules/nutritionModule/models/food.model.dart';
import 'package:performance_tracker/modules/sharedModule/services/common.service.dart';
import 'package:performance_tracker/modules/nutritionModule/src/components/microNutrientList.dart';
import 'package:performance_tracker/constants.ui.dart';

class FoodEntryPage extends StatefulWidget {
  final Food food;
  final bool isCreateMode;
  const FoodEntryPage({
    super.key,
    required this.food,
    required this.isCreateMode,
  });
  @override
  State<StatefulWidget> createState() => _FoodEntryPageState();
}

class _FoodEntryPageState extends State<FoodEntryPage> {
  var caloriesController = TextEditingController();
  Food? standard;
  var commonService = locator<CommonService>();
  bool allowMicroScroll = false;
  @override
  void initState() {
    super.initState();
    caloriesController.text = widget.food.quantity.value.round().toString();
    standard = getStandardFood(widget.food);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: BACKGROUND),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          height: 130,
                          child: Stack(
                            children: [
                              // if(widget.food.imageUrl==null) ...[ // when image looks good
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/food-template2.png',
                                    ),
                                    fit: BoxFit.fitWidth,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              // ]
                              // else ...[
                              //   Container(
                              //     decoration: BoxDecoration(
                              //       image: DecorationImage(
                              //         image: NetworkImage(widget.food.imageUrl!),
                              //         fit: BoxFit.fitWidth,
                              //       ),
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //     width: double.infinity,
                              //     height: double.infinity,
                              //   ),
                              // ],
                              Positioned(
                                bottom: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.food.name,
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
                        SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                'Measure :',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                widget.food.quantity.unit,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: TextField(
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),

                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 0,
                                                ),
                                          ),
                                          controller: caloriesController,
                                          onChanged: (str) {
                                            handleQuantityChange(str);
                                          },
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
                // Macros
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Macro nutrients',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${widget.food.macros.calories.round().toString()} Cal",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.drumstickBite,color:PROTEIN_COLOR,
                                      size: 15,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Protein',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${widget.food.macros.protein.round().toString()} ${widget.food.quantity.unit}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.breadSlice,color:CARBS_COLOR,
                                      size: 15,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Carbohydrate',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${widget.food.macros.carbohydrate.round().toString()} ${widget.food.quantity.unit}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.cheese,color:FAT_COLOR, size: 15),
                                    SizedBox(width: 20),
                                    Text(
                                      'Fat',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${widget.food.macros.fat.round().toString()} ${widget.food.quantity.unit}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.wheatAwn,color:FIBER_COLOR, size: 15),
                                    SizedBox(width: 20),
                                    Text(
                                      'Fiber',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${widget.food.macros.fiber.round().toString()} ${widget.food.quantity.unit}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Micro
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Micro nutrients',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20,bottom: 0,left: 12,right: 12),
                          child: microNutrientList(totalConsumed: widget.food.micros.microMap,allowScroll: allowMicroScroll,),
                        ),
                      ),
                      if(!allowMicroScroll)
                      TextButton(onPressed: (){handleMicroScrollEnable();}, child: Text('Show More' ,style: TextStyle(color: const Color.fromARGB(255, 104, 104, 104)),))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            addFood();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: PRIMARY,
            minimumSize: Size(double.infinity, 50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5),
            ),
          ),
          child: Text(widget.isCreateMode ? "Add To Meal" : "Update Food"),
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

  addFood() {
    Navigator.pop(context, widget.food);
  }

  getStandardFood(Food food) {
    var baseQuant = food.quantity.value;

    var newFood = Food(
      name: food.name,
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

  @override
  void dispose() {
    super.dispose();
    caloriesController.dispose();
  }

  handleMicroScrollEnable()
  {
    this.allowMicroScroll = true;
    setState(() {
    });
  }
}
