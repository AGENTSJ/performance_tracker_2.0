import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';

class WorkoutComponent extends StatefulWidget {
  final Workout workout;
  const WorkoutComponent({super.key, required this.workout});
  @override
  State<WorkoutComponent> createState() => _WorkoutComponentState();
}

class _WorkoutComponentState extends State<WorkoutComponent> {
  static const _headingTextDecor = TextStyle(fontWeight: FontWeight.w500,color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: BoxConstraints(maxHeight: 200,minHeight: 0),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.workout.name ?? '',style: const TextStyle(color: TEXT_PRIMARY,fontWeight: FontWeight.w600,fontSize: 18),),
                Icon(FontAwesomeIcons.book ,color: Colors.grey.shade500,size: 18,),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 8.0,right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('Kg', style: _headingTextDecor)),
                  Expanded(child: Text('PR', style: _headingTextDecor)),
                  Expanded(
                    child: Text(
                      'Today',
                      style: _headingTextDecor,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Save',
                      style: _headingTextDecor,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                  child: Column(
                    children: [
                      ...widget.workout.sets!.map(
                        (set) => Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: SetRowComponent(set: set),
                        ),
                      ),
                    ],
                  ),
                ),
                // child: Container(color: Colors.red,height: 100,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetRowComponent extends StatelessWidget {
  static const inputDecor = InputDecoration(
    fillColor: SURFACE,
    filled: true,
    border: OutlineInputBorder(borderSide: BorderSide.none),
    contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
  );
  static const fieldDecor = TextStyle(fontSize: 15,fontWeight: FontWeight.w400);
  final Set set;
  const SetRowComponent({super.key, required this.set});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("${set.value}",style: fieldDecor,)),
          Expanded(child: Text("${set.pr}",style: fieldDecor,)),
          Expanded(
            child: TextField(
              decoration: inputDecor,
              textAlign: TextAlign.center,
              style: fieldDecor,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.green.shade100,borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.check,
                        size: 12,
                        color: Colors.green.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
