import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/workoutDetails.page.dart';

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
                          color: TEXT_SECONDARY,
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

// class SetRowComponent extends StatefulWidget {
//   final WorkSet set;
//   final Workout workout;

//   const SetRowComponent({
//     super.key,
//     required this.set,
//     required this.workout,
//   });

//   @override
//   State<SetRowComponent> createState() => _SetRowComponentState();
// }

// class _SetRowComponentState extends State<SetRowComponent> {
//   final TextEditingController trackController = TextEditingController();
//   final commonService = locator<CommonService>();
//   final workoutService = locator<WorkoutService>();

//   static const inputDecor = InputDecoration(
//     fillColor: SURFACE,
//     filled: true,
//     border: OutlineInputBorder(borderSide: BorderSide.none),
//     contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
//   );

//   static const fieldDecor = TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w400,
//   );

//   @override
//   void initState() {
//     super.initState();
//     setTrackValue();
//   }

//   void setTrackValue() {
//     var last = widget.set.history.lastOrNull;
//     if (last != null &&
//         commonService.getDateString(last.entryDate) ==
//             commonService.getDateString(DateTime.now())) {
//       trackController.text = last.value.toString();
//     }
//   }

//   void handleTrack() {
//     var rep = int.tryParse(trackController.text);
//     if(rep==null)
//     {
//       return;
//     }
//     workoutService.trackRep(
//       widget.workout,
//       widget.set,
//       rep,
//     );
//     setTrackValue();
//     if(widget.set.pr<rep)
//     {
//       widget.set.pr = rep;
//     }
//     refreshState();
//     Fluttertoast.showToast(msg: "Rep tracked");
//   }

//   @override
//   void dispose() {
//     trackController.dispose();
//     super.dispose();
//   }

//   refreshState()
//   {
//     if(!mounted) return;
//     setState(() {
      
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 27,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(child: Text("${widget.set.value}", style: fieldDecor)),
//           Expanded(child: Text("${widget.set.pr}", style: fieldDecor)),
//           Expanded(
//             child: TextField(
//               decoration: inputDecor,
//               textAlign: TextAlign.center,
//               style: fieldDecor,
//               controller: trackController,
//             ),
//           ),
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GestureDetector(
//                   onTap: handleTrack,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade100,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Icon(
//                         FontAwesomeIcons.check,
//                         size: 12,
//                         color: Colors.green.shade400,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
