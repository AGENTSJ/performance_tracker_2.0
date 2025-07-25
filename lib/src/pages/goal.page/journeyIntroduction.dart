import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';

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
          ],
        ),
      ),
    );
  }
}
