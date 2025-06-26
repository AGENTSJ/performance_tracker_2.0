import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:performance_tracker/DI.dart';
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
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        width: double.infinity,
        constraints: (showMicroAnalysis && !isCommentGenerating)
            ? BoxConstraints(minHeight: 110, maxHeight: 300)
            : BoxConstraints(minHeight: 110, maxHeight: 110),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Center(
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: -20,
                        left: 0,
                        child: Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(190, 45, 150, 129),
                          ),
                        ),
                      ),
                      avatarService.getGreetingAvatar(width: 80, height: 80),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
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
                      SizedBox(width: 30),
                      SizedBox(
                        child: SpinKitSpinningLines(
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!showMicroAnalysis) ...[
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        handleGreetingContainerChange();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          handleGreetingContainerChange();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
