import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/features/Workout/widgets/addVolumeDialog.dart';
import 'package:performance_tracker/src/features/Workout/widgets/progressChart.dart';
import 'package:performance_tracker/src/features/Workout/widgets/setDetails.component.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final Workout workout;
  final bool isCreateMode;
  const WorkoutDetailsPage({
    super.key,
    required this.workout,
    required this.isCreateMode,
  });
  @override
  State<WorkoutDetailsPage> createState() => WorkoutDetailsPageState();
}

class WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  var workoutService = locator<WorkoutService>();
  var workNameController = TextEditingController();
  var workDescriptionController = TextEditingController();
  List<WorkSet> enabledSets = [];
  bool isEditModeOn = false;
  bool isNameEdit = false;
  Workout? workout;
  WorkSet? selectedSetForProgress;
  bool adjustFatigue = false;
  @override
  void initState() {
    super.initState();
    setUpUi();
  }

  setUpUi() async {
    workNameController.text = widget.workout.name;
    workDescriptionController.text = widget.workout.desc;
    if (widget.workout.sets.isNotEmpty) {
      selectedSetForProgress = widget.workout.sets[0];
    }
    workDescriptionController.addListener(() {
      if (!isEditModeOn) {
        setState(() {
          this.isEditModeOn = true;
        });
      }
    });
    if (widget.isCreateMode) {
      workout = await workoutService.addWorkout(widget.workout);
    } else {
      workout = widget.workout;
    }
    setEnabledSets();
    refreshState();
  }

  setEnabledSets() {
    enabledSets = [];
    for (var set in widget.workout.sets) {
      if (set.enabled) {
        enabledSets.add(set);
      }
    }
  }

  handleAddVolume() async {
    final vol = await showDialog<WorkoutVolume>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(87, 90, 90, 90),
      builder: (_) => const AddVolumeDialog(),
    );

    if (vol == null) return;

    widget.workout.volumes.add(vol);

    await workoutService.updateWorkout(widget.workout);

    refreshState();
  }

  handleRemoveVolume(WorkoutVolume vol) async {
    widget.workout.volumes.remove(vol);
    await workoutService.updateWorkout(widget.workout);
    refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: BACKGROUND,
          title: const Text('Workout Details'),
          scrolledUnderElevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(14.0.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // header
                Container(
                  decoration: BoxDecoration(
                    color: SURFACE2,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: isNameEdit
                              ? TextField(
                                  controller: workNameController,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        workout?.name ?? '',
                                        softWrap: true,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          this.isEditModeOn = true;
                                          this.isNameEdit = true;
                                          refreshState();
                                        },
                                        child: Icon(
                                          FontAwesomeIcons.penToSquare,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // sets
                SetDetailsComponent(
                  workout: widget.workout,
                  onSetUpdated: (updated) {
                    handleSetUpdated();
                  },
                ),
                SizedBox(height: 20.h),
                // Volume
                Container(
                  decoration: BoxDecoration(
                    color: SURFACE2,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: BORDER_SECONDARY),
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Volume",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  handleAddVolume();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SURFACE,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size(30.w, 30.h),
                                ),
                                child: Icon(Icons.add, size: 20.w),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          if (widget.workout.volumes.isEmpty) ...[
                            SizedBox(
                              height: 100.h,
                              width: double.infinity,
                              child: empty,
                            ),
                          ] else
                            ...widget.workout.volumes.map(
                              (vol) => Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: BORDER_SECONDARY),
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0.r),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(vol.muscleName)),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: Text(
                                              vol.volume.toStringAsFixed(1),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                handleRemoveVolume(vol);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.r,
                                                      ),
                                                ),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                minimumSize: Size(30.w, 30.h),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 20.w,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
                // Notes
                Container(
                  decoration: BoxDecoration(
                    color: SURFACE2,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: BORDER_SECONDARY),
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.r),
                          child: Row(
                            children: [
                              Text(
                                "Workout Journal",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0.r,
                          vertical: 8.0.r,
                        ),
                        child: TextField(
                          controller: workDescriptionController,
                          minLines: 3,
                          maxLines: null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: SURFACE,
                            hintText: "Add some notes about this workout",
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Progress
                Container(
                  decoration: BoxDecoration(
                    color: SURFACE2,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: BORDER_SECONDARY),
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        // height: 60.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.0.r,
                            horizontal: 12.r,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    "Progress",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      color: TEXT_PRIMARY,
                                    ),
                                  ),
                                  if (selectedSetForProgress != null) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: PRIMARY.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Text(
                                        "Max ${selectedSetForProgress!.pr}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          color: PRIMARY,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        adjustFatigue = !adjustFatigue;
                                      }),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: adjustFatigue
                                              ? PRIMARY.withValues(alpha: 0.12)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                          border: Border.all(
                                            color: adjustFatigue
                                                ? PRIMARY
                                                : BORDER_PRIMARY,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.fireFlameCurved,
                                              size: 11.sp,
                                              color: adjustFatigue
                                                  ? PRIMARY
                                                  : TEXT_SECONDARY,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              "Adjust Fatigue",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: adjustFatigue
                                                    ? PRIMARY
                                                    : TEXT_SECONDARY,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (selectedSetForProgress != null) ...[
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButton2<WorkSet>(
                                        isExpanded: true,
                                        isDense: true,
                                        value: selectedSetForProgress,
                                        hint: Text(
                                          'Select a set',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: TEXT_SECONDARY,
                                          ),
                                        ),
                                        items: widget.workout.sets.map((
                                          WorkSet workSet,
                                        ) {
                                          return DropdownMenuItem<WorkSet>(
                                            value: workSet,
                                            child: Text(
                                              workSet.value.toString(),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: TEXT_PRIMARY,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (WorkSet? newValue) {
                                          setState(() {
                                            selectedSetForProgress = newValue;
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 30.h,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: SURFACE,
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            border: Border.all(
                                              color: BORDER_PRIMARY,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: TEXT_SECONDARY,
                                          ),
                                          iconSize: 20.w,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          padding: EdgeInsets.zero,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            color: SURFACE2,
                                            border: Border.all(
                                              color: BORDER_PRIMARY,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        underline: const SizedBox.shrink(),
                                        menuItemStyleData: MenuItemStyleData(
                                          height: 42.h,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      if (selectedSetForProgress != null &&
                          selectedSetForProgress!.history.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.w, 18.h, 16.w, 6.h),
                          child: SizedBox(
                            height: 220.h,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    "Reps",
                                    style: TextStyle(
                                      color: TEXT_SECONDARY,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: ProgressChart(
                                    isFatigueAdjusted: adjustFatigue,
                                    set: selectedSetForProgress!,
                                    workout: widget.workout,
                                    key: ValueKey(
                                      "${selectedSetForProgress!.value}-$adjustFatigue",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: Center(
                            child: Text(
                              "Attempts",
                              style: TextStyle(
                                color: TEXT_SECONDARY,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: 200.h, width: 200.w, child: empty),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not enough data!!",
                              style: TextStyle(color: TEXT_SECONDARY),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          handleRemove();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: SURFACE,
                          foregroundColor: const Color.fromARGB(
                            148,
                            255,
                            91,
                            91,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            side: BorderSide(
                              color: const Color.fromARGB(148, 255, 91, 91),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.trash,
                              color: const Color.fromARGB(189, 255, 82, 82),
                              size: 12.w,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Remove",
                              style: TextStyle(
                                color: const Color.fromARGB(189, 255, 82, 82),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isEditModeOn
            ? Padding(
                padding: EdgeInsets.all(10.w),
                child: ElevatedButton(
                  onPressed: () {
                    handleUpdateWorkout();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    backgroundColor: PRIMARY,
                  ),
                  child: Text("Update", style: TextStyle(color: TEXT_PRIMARY)),
                ),
              )
            : null,
      ),
    );
  }

  void handleSetUpdated() {
    refreshState();
  }

  handleUpdateWorkout() {
    workout?.name = workNameController.text;
    workout?.desc = workDescriptionController.text;
    workoutService.updateWorkout(workout!);
    isEditModeOn = false;
    isNameEdit = false;
    refreshState();
  }

  handleRemove() async {
    bool remove = await showConfirmation(context) ?? false;
    if (remove) {
      workoutService.removeWorkout(workout!);
      Navigator.of(context).pop(true);
    }
  }

  Future<bool?> showConfirmation(BuildContext context) async {
    return showDialog<bool>(
      barrierColor: const Color.fromARGB(87, 90, 90, 90),
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SURFACE2,
          title: Text('Are you sure ?'),
          content: Text("All the data will be lost"),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }
}
