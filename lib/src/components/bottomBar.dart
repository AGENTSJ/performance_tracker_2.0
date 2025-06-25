import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: PRIMARY,
      height: 60,
      backgroundColor: Colors.transparent,
      animationDuration: Duration(milliseconds: 200),
      items: [
        Icon(Icons.food_bank ,color: Colors.white,),
        Icon(Icons.directions_bike ,color: Colors.white,),
        Icon(Icons.directions_run,color: Colors.white,),
        Icon(Icons.chat,color: Colors.white,),
      ],
    );
  }
}
