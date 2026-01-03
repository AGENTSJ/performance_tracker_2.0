import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/comments.service.dart';

class MicroCommentsWidget extends StatefulWidget {
  final Day? day;
  final Map<String ,MeasuredUnit> microMap;
  const MicroCommentsWidget({super.key, required this.day,required this.microMap});

  @override
  State<StatefulWidget> createState() => MicroCommentsWidgetState();
}

class MicroCommentsWidgetState extends State<MicroCommentsWidget> {
  bool showMicroAnalysis = false;
  final avatarService = locator<AvatarService>();
  final commentService = locator<CommentsService>();
  bool isCommentGenerating = false;

  handleGreetingContainerChange() async {
    if (showMicroAnalysis) {
      showMicroAnalysis = false;
    } else {
      if(isCommentGenerating)
      {
        return;
      }
      isCommentGenerating = true;
      showMicroAnalysis = true;
      setState(() {});
      await commentService.setMicroComments(widget.day!,widget.microMap);
      isCommentGenerating = false;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        handleGreetingContainerChange();
      },
      child: AnimatedContainer(
        key: ValueKey(widget.day!.dayTime),
        duration: Duration(milliseconds: 250), // Animation duration
        curve: Curves.decelerate,
        decoration: BoxDecoration(
          color: SURFACE2,
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
        ),
        width: double.infinity,
        constraints: (showMicroAnalysis && !isCommentGenerating)
            ? BoxConstraints(minHeight: 110.h, maxHeight: 300.h)
            : BoxConstraints(minHeight: 110.h, maxHeight: 110.h),
        child: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80.w,
                height: 80.h,
                child: Center(
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: -20.h,
                        left: 0,
                        child: Container(
                          width: 75.w,
                          height: 75.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(190, 45, 150, 129),
                          ),
                        ),
                      ),
                      avatarService.getGreetingAvatar(width: 80.w, height: 80.h),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              if (isCommentGenerating) ...[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Let me think',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 30.w),
                      SizedBox(
                        child: SpinKitSpinningLines(
                          color: Colors.grey,
                          size: 40.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!showMicroAnalysis) ...[
                Expanded(
                  child: Material(
                    color: SURFACE,
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: () {
                        handleGreetingContainerChange();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: Text(
                          'Hello there 👋\n\nWant me to look through your micros ?',
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Material(
                      color: SURFACE,
                      borderRadius: BorderRadius.circular(8.r),
                      child: InkWell(
                        onTap: () {
                          handleGreetingContainerChange();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Text(
                            widget
                                    .day
                                    ?.comments
                                    ?.microNutrientsComments
                                    ?.comment ??
                                'Ah, leave it.\nIt\'s in the past, focus on now.',
                            style: TextStyle(height: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
