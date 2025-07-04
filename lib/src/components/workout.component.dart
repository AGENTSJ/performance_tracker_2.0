import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/workoutDetails.page.dart';

class WorkoutComponent extends StatefulWidget {
  final Workout workout;
  const WorkoutComponent({super.key, required this.workout});
  @override
  State<WorkoutComponent> createState() => _WorkoutComponentState();
}

class _WorkoutComponentState extends State<WorkoutComponent> {
  static const _headingTextDecor = TextStyle(
    fontWeight: FontWeight.w500,
    color: TEXT_SECONDARY,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: BoxConstraints(maxHeight: 200, minHeight: 0),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    widget.workout.name,
                    maxLines: 1,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: TEXT_PRIMARY,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    handleGoToWorkOutDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(30, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.all(0),
                  ),
                  child: Icon(
                    FontAwesomeIcons.penToSquare,
                    color: TEXT_SECONDARY,
                    size: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (widget.workout.sets.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.weightHanging,
                            color: TEXT_SECONDARY,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text('Kg', style: _headingTextDecor),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.award,
                            color: TEXT_SECONDARY,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text('Max', style: _headingTextDecor),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.calendarCheck,
                            color: TEXT_SECONDARY,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Today',
                            style: _headingTextDecor,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            FontAwesomeIcons.squareCheck,
                            color: TEXT_SECONDARY,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Save',
                            style: _headingTextDecor,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Column(
                      children: [
                        ...widget.workout.sets.map(
                          (set) => Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: SetRowComponent(set: set),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // child: Container(color: Colors.red,height: 100,),
                ),
              ),
            ] else ...[
              SizedBox(height: 20,),
              Material(
                color: SURFACE2,
                child: InkWell(
                  onTap: () {
                    handleGoToWorkOutDetails();
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: SURFACE,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(height: 5),
                          Icon(
                            FontAwesomeIcons.faceGrinWink,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Lets start by adding some sets",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  handleGoToWorkOutDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkoutDetailsPage(workout: widget.workout, isCreateMode: false),
      ),
    );
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }
}

class SetRowComponent extends StatelessWidget {
  static const inputDecor = InputDecoration(
    fillColor: SURFACE,
    filled: true,
    border: OutlineInputBorder(borderSide: BorderSide.none),
    contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
  );
  static const fieldDecor = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
  final Set set;
  const SetRowComponent({super.key, required this.set});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("${set.value}", style: fieldDecor)),
          Expanded(child: Text("${set.pr}", style: fieldDecor)),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      FontAwesomeIcons.check,
                      size: 12,
                      color: Colors.green.shade400,
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
