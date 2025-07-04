import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/workoutDetails.page.dart';

class SetDetailsComponent extends StatefulWidget {
  final Workout workout;
  final ValueChanged<double> onSetAdded;
  const SetDetailsComponent({
    super.key,
    required this.workout,
    required this.onSetAdded,
  });
  @override
  State<SetDetailsComponent> createState() => SetDetailsComponentState();
}

class SetDetailsComponentState extends State<SetDetailsComponent> {
  static const _headingTextDecor = TextStyle(
    fontWeight: FontWeight.w500,
    color: TEXT_SECONDARY,
  );
  bool showTrack = true;
  var enabledButtonDecor = ElevatedButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: Size(30, 30),
    backgroundColor: SURFACE,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(4),
    ),
  );
  var disabledButtonDecor = ElevatedButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: Size(30, 30),
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(4),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 15,
          left: 15,
          right: 15,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        showTrack = true;
                        refreshState();
                      },
                      style: showTrack
                          ? enabledButtonDecor
                          : disabledButtonDecor,
                      child: Text(
                        "Track",
                        style: TextStyle(
                          color: showTrack ? PRIMARY : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showTrack = false;
                        refreshState();
                      },
                      style: !showTrack
                          ? enabledButtonDecor
                          : disabledButtonDecor,
                      child: Text(
                        "Status",
                        style: TextStyle(
                          color: !showTrack ? PRIMARY : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: ()async {
                    var weight = await showMaterialNumberInput(context);
                    widget.onSetAdded(weight!);
                  },
                  style: enabledButtonDecor,
                  child: Icon(Icons.add, size: 20),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              constraints: BoxConstraints(maxHeight: 500, minHeight: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.workout.sets.isNotEmpty) ...[
                    Row(
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (showTrack) ...[
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
                              ] else ...[
                                Icon(
                                  FontAwesomeIcons.chartSimple,
                                  color: TEXT_SECONDARY,
                                  size: 12,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'View',
                                  style: _headingTextDecor,
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
                                'Enable',
                                style: _headingTextDecor,
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          ...widget.workout.sets.map(
                            (set) => Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: SetDetailRowComponent(
                                set: set,
                                showTrack: showTrack,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // child: Container(color: Colors.red,height: 100,),
                    ),
                  ] else ...[
                    SizedBox(height: 20),
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

  Future<double?> showMaterialNumberInput(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<double>(
      barrierColor: const Color.fromARGB(87, 90, 90, 90),
      context: context,
      barrierDismissible: false, // Prevents dismissing without action
      builder: (context) {
        return AlertDialog(
          title: Text('Enter a number'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 24',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(elevation: 0,shadowColor: Colors.transparent),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(elevation: 0,shadowColor: Colors.transparent),
              onPressed: () {
                final input = double.tryParse(controller.text);
                Navigator.of(context).pop(input);
              },
              child: Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

class SetDetailRowComponent extends StatelessWidget {
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
  final bool showTrack;
  const SetDetailRowComponent({
    super.key,
    required this.set,
    required this.showTrack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("${set.value}", style: fieldDecor)),
          Expanded(child: Text("${set.pr}", style: fieldDecor)),
          if (showTrack) ...[
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
          ] else ...[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: SURFACE,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.eye,
                        size: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }
}
