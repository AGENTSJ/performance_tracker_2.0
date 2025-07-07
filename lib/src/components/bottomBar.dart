import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.ui.dart';

class BottomBar extends StatelessWidget {
  final ValueChanged<int> onIndexChange;
  const BottomBar({super.key,required this.onIndexChange});
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: PRIMARY,
      height: 60.h,
      backgroundColor: BACKGROUND,
      animationDuration: Duration(milliseconds: 200),
      items: [
        Icon(Icons.food_bank ,color: CONT_BACKGROUND,),
        Icon(Icons.directions_bike ,color: CONT_BACKGROUND,),
        Icon(Icons.directions_run,color: CONT_BACKGROUND,),
        Icon(FontAwesomeIcons.user,color: CONT_BACKGROUND,),
      ],
      onTap: (index) {
        onIndexChange(index);
      },
    );
  }
}
