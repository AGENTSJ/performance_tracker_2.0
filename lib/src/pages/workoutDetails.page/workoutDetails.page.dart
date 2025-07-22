import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/widgets/progressChart.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/widgets/setDetails.component.dart';

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
  var progressChartScrollController = ScrollController();
  List<WorkSet> enabledSets = [];
  bool isEditModeOn = false;
  bool isNameEdit = false;
  Workout? workout;
  WorkSet? selectedSetForProgress;
  double graphWidth = 25;
  double widthPerPoint = 25;
  // bool
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
      setGraphHeight();
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

  setGraphHeight() {
    graphWidth = widthPerPoint * selectedSetForProgress!.history.length;
    try {
      Future.delayed(Duration(seconds: 2), () {
        if (progressChartScrollController.hasClients) {
          progressChartScrollController.animateTo(
            progressChartScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 400),
            curve: Curves.bounceIn,
          );
        }
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                      child: Icon(FontAwesomeIcons.penToSquare),
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
              // Notes
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0.w),
                  child: Column(
                    children: [
                      Row(
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
                      SizedBox(height: 10.h),
                      TextField(
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Progress
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: BORDER_SECONDARY),
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      height: 50.h,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.0.r,
                          horizontal: 12.r,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Progress",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.sp,
                              ),
                            ),
                            if (selectedSetForProgress != null)
                              Text(
                                "Max : ${selectedSetForProgress!.pr}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                ),
                              ),

                            Row(
                              children: [
                                if (widget.workout.sets.isNotEmpty)
                                  SizedBox(
                                    width: 100.w,
                                    height: 50.h,
                                    child: DropdownButton2<WorkSet>(
                                      isExpanded: true,
                                      isDense: true,
                                      value: selectedSetForProgress,
                                      hint: Text('Select an option'),
                                      items: widget.workout.sets.map((
                                        WorkSet workSet,
                                      ) {
                                        return DropdownMenuItem<WorkSet>(
                                          value: workSet,
                                          child: Container(
                                            padding: EdgeInsets.zero,
                                            decoration: BoxDecoration(),
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                workSet.value.toString(),
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (WorkSet? newValue) {
                                        setState(() {
                                          selectedSetForProgress = newValue;
                                          setGraphHeight();
                                        });
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 50.h,
                                        width: 100.w,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        padding: EdgeInsets.zero,
                                        width: 100.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          color: SURFACE2,
                                        ),
                                      ),
                                      underline: Container(
                                        height: 1,
                                        color: Colors.transparent,
                                      ),
                                      menuItemStyleData: MenuItemStyleData(
                                        height: 40.h,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedSetForProgress != null &&
                        selectedSetForProgress!.history.isNotEmpty) ...[
                      Row(
                        children: [
                          RotatedBox(
                            quarterTurns: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Reps",
                                    style: TextStyle(
                                      color: TEXT_SECONDARY,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Icon(
                                    FontAwesomeIcons.arrowRight,
                                    size: 12.sp,
                                    color: TEXT_SECONDARY,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: progressChartScrollController,
                              child: Container(
                                constraints: BoxConstraints(
                                  minHeight: 200.h,
                                  maxHeight: 200.h,
                                ),
                                width: graphWidth.w,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ProgressChart(
                                          set: selectedSetForProgress!,
                                          key: ValueKey(
                                            selectedSetForProgress!.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Attempts",
                            style: TextStyle(
                              color: TEXT_SECONDARY,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Icon(
                            FontAwesomeIcons.arrowRight,
                            size: 12.sp,
                            color: TEXT_SECONDARY,
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
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
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(148, 255, 91, 91),
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
                child: Text("Update", style: TextStyle(color: Colors.white)),
              ),
            )
          : null,
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
