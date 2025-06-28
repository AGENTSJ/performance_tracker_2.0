import 'package:flutter/material.dart';
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
  bool showWholeGreetings = false;
  final avatarService = locator<AvatarService>();
  final commentService = locator<CommentsService>();
  @override
  bool get wantKeepAlive => true;

  handleGreetingContainerChange() {
    showWholeGreetings = !showWholeGreetings;
    setState(() {});
  }

  @override
  void initState() {
    print('greetings ran');
    super.initState();
    commentService
        .setDietComments(widget.day!)
        .then((comment) => {setState(() {})});
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
          color: CONT_BACKGROUND,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        width: double.infinity,
        constraints: showWholeGreetings
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
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: SURFACE2,
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
                                    ?.overallDietComments
                                    ?.comment ??
                                'Hmmmm\n\nLooks like you forgot to track your calories this day.',
                            style: TextStyle(height: 1.9),
                          ),
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
