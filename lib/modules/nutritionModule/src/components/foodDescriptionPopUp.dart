import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/modules/nutritionModule/services/foods.service.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/foodEntry.page/foodEntry.page.dart';
import 'package:performance_tracker/constants.ui.dart';

class FoodDescriptionPopUp extends StatefulWidget {
  final String foodName;
  const FoodDescriptionPopUp({super.key, required this.foodName});
  @override
  State<StatefulWidget> createState() => _FoodDescriptionPopupState();
}

class _FoodDescriptionPopupState extends State<FoodDescriptionPopUp> {
  late final TextEditingController descriptionController =
      TextEditingController();
  var foodService = locator<FoodService>();
  bool isGenerating = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      title: Text(widget.foodName),
      content: isGenerating
          ? Material(
              child: Container(
                color: SURFACE,
                height: 200,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitSpinningLines(color: PRIMARY, size: 50),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Master chef is cooking ✨✨",
                        style: TextStyle(fontSize: 14, height: 2),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(
              height: 200,
              width: double.infinity,
              child: Center(
                child: TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter a description for ${widget.foodName}',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                ),
              ),
            ),
      actions: [
        if (!isGenerating) ...[
          TextButton(
            onPressed: () {
              generateFood();
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Back'),
          ),
        ],
      ],
    );
  }

  generateFood() async {
    setState(() {
      isGenerating = true;
    });
    var food = await foodService.AI_CreateFood(
      widget.foodName,
      descriptionController.text,
    );
    setState(() {
      isGenerating = false;
    });

    if (food != null) {
      var returnedFood = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodEntryPage(food: food, isCreateMode: true),
        ),
      );
      Navigator.of(context).pop(returnedFood);
    } else {
      Fluttertoast.showToast(
        msg: "Mysterious food indeed !!, Try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        webBgColor: "white",
      );
    }
  }
}
