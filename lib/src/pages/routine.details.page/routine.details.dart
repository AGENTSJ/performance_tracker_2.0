import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/components/selectWorkout.dart';

class RoutineDetails extends StatefulWidget {
  final Routine routine;
  final bool isCreateMode;
  const RoutineDetails({
    super.key,
    required this.routine,
    required this.isCreateMode,
  });
  @override
  State<RoutineDetails> createState() => RoutineDetailsState();
}

class RoutineDetailsState extends State<RoutineDetails> {
  var routineService = locator<RoutineService>();
  var workNameController = TextEditingController();
  bool isEditModeOn = false;
  Routine? routine;
  List<Workout> workouts = [];
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      workNameController.text = widget.routine.name;
      if (widget.isCreateMode) {
        var routineKey = await routineService.addRoutine(widget.routine);
        routine = await routineService.getRoutineById(routineKey);
        workouts = await routineService.getRoutinesWorkouts(routine!);
      } else {
        routine = widget.routine;
      }
      refreshState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Routine Details'),
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
                        child: isEditModeOn
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
                                      routine?.name ?? '',
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
              // Workouts
              Container(
                decoration: BoxDecoration(
                  color: SURFACE2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Workouts",style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w500),),
                          TextButton(
                            onPressed: () {
                              handleAddWorkout();
                            },
                            child: Icon(FontAwesomeIcons.plus,size: 20.sp,),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          if(workouts.isEmpty)
                          Container(
                            decoration: BoxDecoration(color: SURFACE2,borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  children: [
                                    Icon(FontAwesomeIcons.faceGrinWink,color: Colors.grey,),
                                    SizedBox(height: 10.h,),
                                    Text("Add workouts to routine",style:TextStyle(color: Colors.grey))
                                  ],
                              ),
                            ),
                          ),

                          ...workouts.map(
                            (work) => Row(children: [Text(work.name)]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                            "Routine Description",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      TextField(
                        minLines: 3,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(53, 202, 202, 202),
                          hintText: "Add some notes about this routine",
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
    routine?.name = workNameController.text;
    routineService.updateRoutine(routine!);
    isEditModeOn = false;
    refreshState();
  }

  handleRemove() async {
    bool remove = await showConfirmation(context) ?? false;
    if (remove) {
      routineService.removeRoutine(routine!);
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

  handleAddWorkout() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SelectWorkout(selectedWorkouts: workouts),
    );
    refreshState();
  }
}
