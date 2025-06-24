import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/src/pages/AddFood.page.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class FoodDescriptionPopUp extends StatefulWidget {
  final String foodName;
  const FoodDescriptionPopUp({
    super.key,
    required this.foodName,
  });
  @override
  State<StatefulWidget> createState()=> _FoodDescriptionPopupState();
}

class _FoodDescriptionPopupState extends State<FoodDescriptionPopUp> {
  late final TextEditingController descriptionController = TextEditingController();
  var foodService  = locator<FoodService>();
  bool isGenerating = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.foodName),
      content: 
      isGenerating?
        SizedBox(
          height: 80,
          width: 50,
          child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: PRIMARY,),
              Text("Wait few seconds...")
            ],
          ))
        )
      : 
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            hintText: 'Enter a description for ${widget.foodName}',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      actions: [
        TextButton(
          onPressed: () {
            generateFood();
          },
          child: Text('Add'),
        ),
        TextButton(onPressed: (){Navigator.pop(context);}, child: Text('Back')),
      ],
    );
  }

  generateFood() async
  {
    setState(() {
      isGenerating = true;
    });
    var food = await foodService.AI_CreateFood(widget.foodName, descriptionController.text);
    setState(() {
      isGenerating= false;
    });
    
    if(food!=null)
    {
      var returnedFood =  await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddFoodModal(food: food,isCreateMode: true,)),
      );
      Navigator.of(context).pop(returnedFood);
    }else
    {
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