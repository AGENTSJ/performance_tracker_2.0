import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.ui.dart';

class BottomBar extends StatelessWidget {
  final ValueChanged<int> onIndexChange;
  const BottomBar({super.key,required this.onIndexChange});
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: PRIMARY,
      height: 60,
      backgroundColor: BACKGROUND,
      animationDuration: Duration(milliseconds: 200),
      items: [
        Icon(Icons.food_bank ,color: Colors.white,),
        Icon(FontAwesomeIcons.user,color: Colors.white,),
        Icon(Icons.directions_bike ,color: Colors.white,),
        Icon(Icons.directions_run,color: Colors.white,),
      ],
      onTap: (index) {
        onIndexChange(index);
      },
    );
  }
}
