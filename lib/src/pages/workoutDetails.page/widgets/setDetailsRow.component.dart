import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';

class SetDetailRowComponent extends StatefulWidget {
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

  final WorkSet set;
  final bool showTrack;
  final Workout workout;
  final ValueChanged onSetUpdated;
  const SetDetailRowComponent({
    super.key,
    required this.set,
    required this.showTrack,
    required this.workout,
    required this.onSetUpdated
  });

  @override
  State<SetDetailRowComponent> createState() => SetDetailRowComponentState();
}

class SetDetailRowComponentState extends State<SetDetailRowComponent> {
  late bool isEnabled;
  var routineService = locator<RoutineService>();
  @override
  void initState() {
    super.initState();
    isEnabled = widget.set.enabled;
  }

  void handleToggleEnable(bool val) async {
    isEnabled = val;
    widget.set.enabled = val;
    await routineService.updateWorkout(widget.workout);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "${widget.set.value}",
              style: SetDetailRowComponent.fieldDecor,
            ),
          ),
          Expanded(
            child: Text(
              "${widget.set.pr}",
              style: SetDetailRowComponent.fieldDecor,
            ),
          ),
          if (widget.showTrack) ...[
            Expanded(
              child: TextField(
                decoration: SetDetailRowComponent.inputDecor,
                textAlign: TextAlign.center,
                style: SetDetailRowComponent.fieldDecor,
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
          ] else ...[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(20, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color.fromARGB(104, 255, 163, 163),
                      foregroundColor: const Color.fromARGB(104, 255, 147, 147),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(4),
                      ),
                    ),
                    onPressed: () async {
                      var remove =  await showConfirmDialog(context, widget.set.value);
                      if(remove!=null && remove)
                      {
                        handleRemoveSet(widget.set);
                      }
                    },
                    child: Icon(
                      FontAwesomeIcons.trash,
                      size: 12,
                      color: const Color.fromARGB(149, 255, 111, 111),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 0.6,
                    child: Switch(
                      value: isEnabled,
                      onChanged: handleToggleEnable,
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

  handleRemoveSet(WorkSet setToRemove)
  {
    widget.workout.sets.remove(setToRemove);
    widget.onSetUpdated(true);
  }

  Future<bool?> showConfirmDialog(BuildContext context, double weight) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SURFACE2,
        title: Text("Remove $weight ?"),
        content: Text("Do you really want to delete this item?"),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
