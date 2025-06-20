import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class NutritionAnalysisPage  extends StatefulWidget{
  final Day day;
  const NutritionAnalysisPage({super.key,required this.day});
  @override
  State<StatefulWidget> createState() =>_NutritionAnalysisState();
}

class _NutritionAnalysisState extends State<NutritionAnalysisPage>
{
  final DayService dayService = locator<DayService>();
  double protein = 0;
  double fat = 0;
  double carbohydrate = 0;
  double fiber = 0;
  String unit ='g';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            // Todays Macro analysis
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white
              ),
              constraints: BoxConstraints(
                maxHeight: 250
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // heading
                    Row(
                      children: [
                        Text('Todays Analysis',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),)
                      ],
                    ),
                    SizedBox(height: 15,),
                    // calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: BoxBorder.all(color: PRIMARY,width: 2)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Icon(Icons.restaurant,color: PRIMARY,size: 30,),
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${dayService.getDaysCalories(widget.day)} / 2000 Cal", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
                        )
                      ],  
                    ),
                    SizedBox(height: 20,),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Protein'),
                              Text("${protein.round().toString()} $unit"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Carbohydrate'),
                              Text(
                                "${carbohydrate.round().toString()} $unit",
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Fat'),
                              Text("${fat.round().toString()} $unit"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Fiber'),
                              Text("${fiber.round().toString()} $unit"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              flex: 1, 
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Colors.white),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Micro nutrients analysis")
                      ],
                    )
                  ],
                ),
              )
            )  
          ],
        ),
      ),
    );
  }
}