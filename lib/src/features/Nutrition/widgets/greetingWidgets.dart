import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/comments.service.dart';

class GreetingsWidget extends StatefulWidget {
  final Day? day;
  const GreetingsWidget({super.key, required this.day});

  @override
  State<StatefulWidget> createState() => GreetingsWidgetState();
}

class GreetingsWidgetState extends State<GreetingsWidget>
    with AutomaticKeepAliveClientMixin {
  final String greetingPlaceHolder = "Hello there 😊 \n\nWant to know how you did today?";
  bool showWholeGreetings = false;
  bool isGenerating = false;
  final avatarService = locator<AvatarService>();
  final commentService = locator<CommentsService>();
  @override
  bool get wantKeepAlive => true;

  handleGreetingContainerChange()async {
    if(showWholeGreetings)
    {
      showWholeGreetings = false;
    }
    else
    {
      await handleGetGreeting();
      showWholeGreetings = true;
    }
    refreshState();
  }

  @override
  void initState() {
    handleGetGreeting();
    super.initState();
  }

  refreshState()
  {
    if(!mounted) return;
    setState(() {});
  }

  handleGetGreeting()async
  {
    if(isGenerating) return;
    isGenerating = true;
    refreshState();
    await commentService.setDietComments(widget.day!);
    isGenerating = false;
    refreshState();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        handleGreetingContainerChange();
      },
      child: AnimatedContainer(
        key: ValueKey(widget.day!.dayTime),
        duration: Duration(milliseconds: 250), // Animation duration
        curve: Curves.decelerate,
        decoration: BoxDecoration(
          color: CONT_BACKGROUND,
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
        ),
        width: double.infinity,
        constraints: showWholeGreetings
            ? BoxConstraints(minHeight: 110.h, maxHeight: 300.h)
            : BoxConstraints(minHeight: 110.h, maxHeight: 110.h),
        child:isGenerating?SizedBox(
          height: 110.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hmmm lets see..'),
              SizedBox(width: 20.w,),
              SpinKitSpinningLines(color: TEXT_SECONDARY,size: 30.w,),
            ],
          ),
        ) :Padding(
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
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Material(
                      color: SURFACE,
                      borderRadius: BorderRadius.circular(8.r),
                      child: InkWell(
                        onTap: () {
                          handleGreetingContainerChange();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: showWholeGreetings? Text(
                            widget
                                    .day
                                    ?.comments
                                    ?.overallDietComments
                                    ?.comment ??
                                'Hmmmm\n\nLooks like you forgot to track your calories this day.',
                            style: TextStyle(height: 1.6),
                          ):Text(greetingPlaceHolder),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
