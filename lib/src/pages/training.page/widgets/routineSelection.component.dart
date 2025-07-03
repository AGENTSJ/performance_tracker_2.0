import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';

class RoutineSelection extends StatefulWidget {
  const RoutineSelection({Key? key}) : super(key: key);
  
  @override
  State<RoutineSelection> createState() => _RoutineSelectionState();
}

class _RoutineSelectionState extends State<RoutineSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(color: SURFACE2,borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(height: 100,child: TextField())
              ],
            ),
            Row(
              children: [
                Text("Chest day"),
              ],
            )
          ],
        ),
      ),
    );
  }
}