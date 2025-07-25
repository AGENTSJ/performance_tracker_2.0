import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/src/components/goals.widget.dart';

class JourneyIntroduction extends StatefulWidget {
  const JourneyIntroduction({super.key});

  @override
  State<JourneyIntroduction> createState() => _JourneyIntroductionState();
}

class _JourneyIntroductionState extends State<JourneyIntroduction> {
  final avatarService = locator<AvatarService>();
  final journeyService = locator<JourneyService>();
  final userService = locator<UserService>();
  late final Widget avatar;
  User? user;
  final String introText =
      "Hello there 😊\nYou dont have an active journey !!\nStart now ?";

  @override
  void initState() {
    super.initState();
    setUpUi();
  }

  setUpUi() async {
    avatar = avatarService.getDefaultAvatar(width: 80.w, height: 80.h);
    user = await userService.getUserData();
  }

  void handleCreateJourney() async {
    bool? didUpdate = await showDialog(
      context: context,
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(14.0.r),
            child: Container(
              decoration: BoxDecoration(
                color: SURFACE2,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  child: GoalsWidget(
                    user: user!,
                    onUpdate: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (didUpdate != null && didUpdate) {
      user = await userService.getUserData();
      var newJourney = Journey(
        startDate: DateTime.now(),
        userTarget: user!.userGoals,
        caloriesChangeAchieved: 0,
        stepsWalked: 0,
        onProgress: true,
        lastUpdated: null,
      );
      await journeyService.createJourney(newJourney);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8.r),
      ),
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(12.0.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(child: avatar),
                SizedBox(width: 5.w),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: SURFACE,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: Text(introText, style: TextStyle(height: 1.5.h)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    handleCreateJourney();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text("Start a journey"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
