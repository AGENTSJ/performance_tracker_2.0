import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/workout.service.dart';

class SetDetailRowComponent extends StatefulWidget {
  static final fieldDecor = TextStyle(
    fontSize: 15.sp,
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
    required this.onSetUpdated,
  });

  @override
  State<SetDetailRowComponent> createState() => SetDetailRowComponentState();
}

class SetDetailRowComponentState extends State<SetDetailRowComponent> {
  var inputDecor = InputDecoration(
    fillColor: SURFACE2,
    filled: true,
    border: OutlineInputBorder(borderSide: BorderSide.none),
    hintText: 'Reps..',
    hintStyle: TextStyle(color: TEXT_SECONDARY, fontSize: 12.sp),
    contentPadding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 0),
  );
  late bool isEnabled;
  var workoutService = locator<WorkoutService>();
  final commonService = locator<CommonService>();
  final trackController = TextEditingController();
  @override
  void initState() {
    super.initState();
    isEnabled = widget.set.enabled;
    setTrackValue();
  }

  void setTrackValue() {
    var last = widget.set.history.lastOrNull;
    if (last != null &&
        commonService.getDateString(last.entryDate) ==
            commonService.getDateString(DateTime.now())) {
      trackController.text = last.value.toString();
    }
  }

  void handleTrack() {
    var rep = int.tryParse(trackController.text);
    if (rep == null) {
      return;
    }
    workoutService.trackRep(widget.workout, widget.set, rep);
    setTrackValue();
    if (widget.set.pr < rep) {
      widget.set.pr = rep;
    }
    refreshState();
    Fluttertoast.showToast(msg: "Rep tracked");
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  void handleToggleEnable(bool val) async {
    isEnabled = val;
    widget.set.enabled = val;
    await workoutService.updateWorkout(widget.workout);
    setState(() {});
    // Keep the parent's "Track" (enabled-only) list in sync. No DB reload
    // needed — the flag was already mutated in-place and persisted.
    widget.onSetUpdated(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        border: Border(bottom: BorderSide(color: BORDER_SECONDARY)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      height: 40.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0.h),
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
                child: SizedBox(
                  height: 27.h,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: inputDecor,
                    textAlign: TextAlign.center,
                    style: SetDetailRowComponent.fieldDecor,
                    controller: trackController,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        handleTrack();
                      },
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size(30.w, 30.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.r))
                      ),
                      child: Icon(FontAwesomeIcons.check, size: 14.w),
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
                        minimumSize: Size(20.w, 20.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                        foregroundColor: const Color.fromARGB(
                          104,
                          255,
                          147,
                          147,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(4.r),
                        ),
                      ),
                      onPressed: () async {
                        var remove = await showConfirmDialog(
                          context,
                          widget.set.value,
                        );
                        if (remove != null && remove) {
                          handleRemoveSet(widget.set);
                        }
                      },
                      child: Icon(
                        FontAwesomeIcons.trash,
                        size: 12.w,
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
      ),
    );
  }

  handleRemoveSet(WorkSet setToRemove) async {
    widget.workout.sets.remove(setToRemove);
    await workoutService.updateWorkout(widget.workout);
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
                borderRadius: BorderRadiusGeometry.circular(8.r),
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
                borderRadius: BorderRadiusGeometry.circular(8.r),
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
