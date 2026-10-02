import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/src/features/Workout/pages/workoutDetails.page.dart';

class WorkoutComponent extends StatefulWidget {
  final Workout workout;
  final ValueChanged<bool> onUpdated;
  const WorkoutComponent({super.key, required this.workout,required this.onUpdated});
  @override
  State<WorkoutComponent> createState() => WorkoutComponentState();
}

class WorkoutComponentState extends State<WorkoutComponent> {
  List<WorkSet> enabledSets = [];

  @override
  void initState()
  {
    setEnabledSets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SURFACE2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          handleGoToWorkOutDetails();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.0.h,horizontal: 15.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 30.h,
                    width: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: TEXT_SECONDARY)
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right:3.5.w),
                        child: Icon(
                          FontAwesomeIcons.dumbbell,
                          color: TEXT_SECONDARY,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w,),
                  Expanded(
                    child: SizedBox(
                      child: Text(
                        widget.workout.name,
                        maxLines: 1,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleGoToWorkOutDetails() async {
    var removed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkoutDetailsPage(workout: widget.workout, isCreateMode: false),
      ),
    );
    if(removed!=null)
    {
      widget.onUpdated(removed);
    }
    setEnabledSets();
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }
  setEnabledSets()
  {
    enabledSets = [];
    widget.workout.sets.forEach((workSet){
      if(workSet.enabled)
      {
        enabledSets.add(workSet);
      }
    });
  }
}