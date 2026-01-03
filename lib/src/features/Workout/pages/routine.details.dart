import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/components/selectWorkout.dart';
import 'package:performance_tracker/src/features/Workout/pages/workoutDetails.page.dart';

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
  var routineNameController = TextEditingController();
  var routineDescriptionController = TextEditingController();
  bool isEditModeOn = false;
  bool isNameEdit = false;
  Routine? routine;
  List<Workout> workouts = [];
  List<WorkoutVolume> volumes = [];
  var index = 0;
  @override
  void initState() {
    routineDescriptionController.text = widget.routine.desc;
    routineDescriptionController.addListener(() {
      if (!isEditModeOn) {
        setState(() {
          this.isEditModeOn = true;
        });
      }
    });
    setRoutineUi(widget.isCreateMode);
    super.initState();
  }

  setRoutineUi(bool isCreateMode) async {
    routineNameController.text = widget.routine.name;
    if (isCreateMode) {
      var routineKey = await routineService.addRoutine(widget.routine);
      routine = await routineService.getRoutineById(routineKey);
    } else {
      routine = widget.routine;
    }
    workouts = await routineService.getRoutinesWorkouts(routine!);
    setVolumes();
    refreshState();
  }

  setVolumes() {
    volumes = [];
    for (var work in workouts) {
      for (var vol in work.volumes) {
        var presentVol = getVolumeByName(vol.muscleName);
        if (presentVol == null) {
          vol = WorkoutVolume(muscleName: vol.muscleName, volume: vol.volume);
          vol.volume =
              vol.volume * work.sets.where((set) => set.enabled).length;
          volumes.add(vol);
        } else {
          presentVol.volume +=
              vol.volume * work.sets.where((set) => set.enabled).length;
        }
      }
    }
  }

  WorkoutVolume? getVolumeByName(String name) {
    for (var vol in volumes) {
      if (vol.muscleName == name) {
        return vol;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Routine Details'),
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
                                controller: routineNameController,
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
              // Workouts
              Container(
                decoration: BoxDecoration(
                  color: SURFACE2,
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: BORDER_SECONDARY),
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Workouts",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SURFACE,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size(20.w, 20.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8.r,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                handleAddRoutine();
                              },
                              child: Icon(Icons.add, size: 20.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (workouts.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(12.0.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: SURFACE2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(
                                  FontAwesomeIcons.faceGrinWink,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "Add workouts to routine",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (workouts.isNotEmpty)
                      Material(
                        color: SURFACE2,
                        borderRadius: BorderRadius.circular(8.r),
                        child: ReorderableListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            ...workouts.map((work) {
                              index++;
                              return Material(
                                key: ValueKey("${work.name}$index"),
                                color: SURFACE2,
                                child: InkWell(
                                  onTap: () {
                                    handleGoToWorkOutDetails(work);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: BORDER_SECONDARY,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0.r),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.drag_handle,
                                            size: 17.sp,
                                            color: TEXT_SECONDARY,
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              "${work.name} (${work.sets.where((s) => s.enabled).length})",
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            style: ElevatedButton.styleFrom(
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              minimumSize: Size(20.w, 20.h),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadiusGeometry.circular(
                                                      8.r,
                                                    ),
                                              ),
                                            ),
                                            onPressed: () {
                                              handleRemoveWorkout(work);
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            var work = workouts.removeAt(oldIndex);
                            var id = widget.routine.workoutsIds.removeAt(
                              oldIndex,
                            );
                            workouts.insert(newIndex, work);
                            widget.routine.workoutsIds.insert(newIndex, id);
                            refreshState();
                            routineService.updateRoutine(routine!);
                          },
                        ),
                      ),
                  ],
                ),
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
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        if (volumes.isEmpty) ...[
                          SizedBox(
                            height: 100.h,
                            width: double.infinity,
                            child: empty,
                          ),
                        ] else
                          ...volumes.map((vol) {
                            return Container(
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
                                      child: Center(
                                        child: Text(vol.volume.toStringAsFixed(1)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
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
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: BORDER_SECONDARY),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0.r),
                        child: Row(
                          children: [
                            Text(
                              "Routine Description",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0.r),
                      child: TextField(
                        controller: routineDescriptionController,
                        minLines: 3,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: SURFACE,
                          hintText: "Add some notes about this routine",
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
                  handleUpdateRoutine();
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
    );
  }

  void handleSetUpdated() {
    refreshState();
  }

  handleGoToWorkOutDetails(Workout workout) async {
    var removed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkoutDetailsPage(workout: workout, isCreateMode: false),
      ),
    );
    if (removed != null) {
      this.workouts.remove(workout);
      this.routine!.workoutsIds.remove(workout.key);
      await handleUpdateRoutine();
    }
    refreshState();
  }

  handleUpdateRoutine() async {
    routine?.name = routineNameController.text;
    routine?.desc = routineDescriptionController.text;
    await routineService.updateRoutine(routine!);
    isEditModeOn = false;
    isNameEdit = false;
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

  handleAddRoutine() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: SURFACE2,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: 400.h,
          child: SelectWorkout(selectedWorkouts: workouts),
        ),
      ),
    );
    routine?.workoutsIds = [];
    for (var work in workouts) {
      routine?.workoutsIds.add(work.key);
    }
    await routineService.updateRoutine(routine!);
    setVolumes();
    refreshState();
  }

  handleRemoveWorkout(Workout work) async {
    workouts.remove(work);
    widget.routine.workoutsIds.remove(work.key);
    await routineService.updateRoutine(widget.routine);
    setVolumes();
    refreshState();
  }
}
