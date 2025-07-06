import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/widgets/setDetailsRow.component.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/workoutDetails.page.dart';

class SetDetailsComponent extends StatefulWidget {
  final Workout workout;
  final ValueChanged<bool> onSetUpdated;
  const SetDetailsComponent({
    super.key,
    required this.workout,
    required this.onSetUpdated,
  });
  @override
  State<SetDetailsComponent> createState() => SetDetailsComponentState();
}

class SetDetailsComponentState extends State<SetDetailsComponent> {
  bool showTrack = true;
  static const _headingTextDecor = TextStyle(
    fontWeight: FontWeight.w500,
    color: TEXT_SECONDARY,
  );
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
  var workoutService = locator<WorkoutService>();
  @override
  void initState() {
    super.initState();
  }

  setSets(bool setsUpdated) async {
    if(setsUpdated)
    {
      var work = await workoutService.getWorkOutById(widget.workout.key);
      widget.workout.sets = work!.sets;
    }
    refreshState();
  }

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
                  onPressed: () async {
                    var weight = await showMaterialNumberInput(context);
                    if (weight != null) {
                      handleAddNewSet(weight);
                      widget.onSetUpdated(true);
                    }
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                                Expanded(
                                  child: Text(
                                    'Kg',
                                    style: _headingTextDecor,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                ),
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
                                Expanded(
                                  child: Text(
                                    'Max',
                                    style: _headingTextDecor,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showTrack) ...[
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.solidCalendarCheck,
                                    color: TEXT_SECONDARY,
                                    size: 12,
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Today',
                                      style: _headingTextDecor,
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.solidSquareCheck,
                                    color: TEXT_SECONDARY,
                                    size: 12,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Track',
                                    style: _headingTextDecor,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.trash,
                                    color: TEXT_SECONDARY,
                                    size: 12,
                                  ),
                                  SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      'Remove',
                                      style: _headingTextDecor,
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.solidSquareCheck,
                                    color: TEXT_SECONDARY,
                                    size: 12,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Enable',
                                    style: _headingTextDecor,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
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
                                workout: widget.workout,
                                onSetUpdated: (value) {
                                  setSets(value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 20),
                    Material(
                      color: SURFACE2,
                      child: InkWell(
                        onTap: () {
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
  handleAddNewSet(double weight)
  {
    var set = WorkSet(value: weight, history: [], pr: 0, enabled: true);
    widget.workout.sets.add(set);
    workoutService.updateWorkout(widget.workout);
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
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SURFACE2,
          title: Text('Enter weight in Kg'),
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
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
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
