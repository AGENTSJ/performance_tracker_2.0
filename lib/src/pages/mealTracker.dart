import 'package:flutter/material.dart';

class MealTrackerPage extends StatefulWidget{
  @override
  State<MealTrackerPage> createState()=>_MealTrackerState();
}

class _MealTrackerState extends State<MealTrackerPage>
{
  @override
  Widget build(BuildContext context)
  {
    return Container(
      child: Column(
        children: [
          Text('Inside Tracker'),
          ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text('Go back'))
        ],
      ),
    );
  }
}
