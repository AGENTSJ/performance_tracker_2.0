import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.ui.dart';

class ExerciseWidget extends StatefulWidget {
  final String name;
  const ExerciseWidget({super.key, required this.name});
  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: CONT_BACKGROUND),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [ 
                Icon(FontAwesomeIcons.dumbbell),
                Text(widget.name)
              ],
            )
          ]
        ),
      ),
    );
  }
}
