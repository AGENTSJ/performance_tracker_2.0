import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/src/components/selectWorkout.dart';
import 'package:performance_tracker/src/components/workout.component.dart';
import 'package:performance_tracker/src/pages/advices.page/advices.page.dart';
import 'package:performance_tracker/src/pages/loading.page/loading.page.dart';
import 'package:performance_tracker/src/pages/workouts.page/workouts.page.dart';
import 'package:performance_tracker/src/pages/routines.page/routines.page.dart';
import 'package:performance_tracker/src/components/routineSelection.component.dart';

class TrainingModulePage extends StatefulWidget {
  const TrainingModulePage({super.key});

  @override
  State<TrainingModulePage> createState() => TrainingModulePageState();
}

class TrainingModulePageState extends State<TrainingModulePage> {
  final workoutService = locator<WorkoutService>();
  final routineService = locator<RoutineService>();
  final userService = locator<UserService>();
  final buttonDecor = ElevatedButton.styleFrom(
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(side: BorderSide.none),
  );
  final addFromButtonDecor = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    minimumSize: Size(0, 0),
    textStyle: TextStyle(fontSize: 14.sp),
    elevation: 0,
    shadowColor: Colors.transparent,
  );
  Routine? routine;
  List<Workout> workouts = [];
  User? user;
  Day? today;
  bool isLoaded = false;
  var dayService = locator<DayService>();
  @override
  void initState() {
    setRoutineUi();
    super.initState();
  }

  setRoutineUi() async {
    user = await userService.getUserData();
    today = await dayService.getDayDataByDate(DateTime.now());
    routine = await routineService.getRoutineById(today!.routineId!);
    if (routine != null) {
      workouts = await routineService.getRoutinesWorkouts(routine!);
    }
    isLoaded = true;
    await Future.delayed(Duration(milliseconds: WAITING_PERIOD_PAGE_SWITCH_MS));
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BACKGROUND,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0.r),
          child: Text(
            "Hi, ${user?.name}",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 23.sp),
          ),
        ),
      ),
      body: !isLoaded
          ? LoadingPage()
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(14.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      "Manage",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Material(
                                color: SURFACE2,
                                borderRadius: BorderRadius.circular(12.r),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RoutinesPage(),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 60.h,
                                    width: 140.w,
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.solidCalendar,
                                            size: 16.sp,
                                            color: TEXT_SECONDARY,
                                          ),
                                          SizedBox(width: 20.w),
                                          Text(
                                            "Routines",
                                            style: TextStyle(
                                              color: TEXT_TERTIARY,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Material(
                                color: SURFACE2,
                                borderRadius: BorderRadius.circular(12.r),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WorkoutsPage(),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 60.h,
                                    width: 140.w,
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.layerGroup,
                                            size: 16.sp,
                                            color: TEXT_SECONDARY,
                                          ),
                                          SizedBox(width: 20.w),
                                          Text(
                                            "Workouts",
                                            style: TextStyle(
                                              color: TEXT_TERTIARY,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Material(
                                color: SURFACE2,
                                borderRadius: BorderRadius.circular(12.r),
                                child: InkWell(
                                  onTap: () {
                                    handleNavigateToAdvices();
                                  },
                                  child: SizedBox(
                                    height: 60.h,
                                    width: 140.w,
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.brain,
                                            size: 16.sp,
                                            color: TEXT_SECONDARY,
                                          ),
                                          SizedBox(width: 20.w),
                                          Text(
                                            "Advices",
                                            style: TextStyle(
                                              color: TEXT_TERTIARY,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Todays workouts",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size(5.w, 5.h),
                          ),
                          onPressed: () {
                            handleAddWorkout();
                          },
                          icon: Icon(
                            FontAwesomeIcons.plus,
                            size: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      decoration: BoxDecoration(
                        color: SURFACE2,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ReorderableListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          var work = workouts.removeAt(oldIndex);
                          var id = routine!.workoutsIds.removeAt(oldIndex);
                          workouts.insert(newIndex, work);
                          routine!.workoutsIds.insert(newIndex, id);
                          routineService.updateRoutine(routine!);
                          refreshState();
                        },
                        children: [
                          ...workouts.map(
                            (work) => Container(
                              key: ValueKey(work),
                              decoration: BoxDecoration(
                                color: SURFACE2,
                                border: Border(
                                  bottom: BorderSide(color: BORDER_PRIMARY),
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Stack(
                                  children: [
                                    WorkoutComponent(
                                      workout: work,
                                      onUpdated: (value) {},
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 12.r,
                                      child: IconButton(
                                        onPressed: () {
                                          handleRemoveWorkout(work);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: SURFACE,
                                        ),
                                        icon: Icon(
                                          FontAwesomeIcons.xmark,
                                          size: 18.sp,
                                          color: TEXT_SECONDARY,
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
                    ),

                    if (workouts.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.faceGrinWink,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "Add some workouts to get started",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  handleRemoveWorkout(Workout work) async {
    workouts.remove(work);
    routine!.workoutsIds = [];
    for (var workt in workouts) {
      routine!.workoutsIds.add(workt.key);
    }
    await routineService.updateRoutine(routine!);
    setState(() {});
  }
  var trainerService = locator<TrainerAgentService>();
  handleNavigateToAdvices()
  {
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdvicesPage()));
  }
  handleAddWorkout() async {
    await showModalBottomSheet(
      backgroundColor: SURFACE2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20.r)),
      ),
      context: context,
      builder: (BuildContext context) => SizedBox(
        child: SizedBox(
          height: 600.h,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  children: [
                    SelectWorkout(selectedWorkouts: workouts),
                    RoutineSelection(selectedWorkouts: workouts),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Swipe to select from workouts or routines",
                      style: TextStyle(color: TEXT_SECONDARY),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    routine?.workoutsIds = [];
    for (var work in workouts) {
      routine?.workoutsIds.add(work.key);
    }
    routineService.updateRoutine(routine!);
    setState(() {});
  }
}
