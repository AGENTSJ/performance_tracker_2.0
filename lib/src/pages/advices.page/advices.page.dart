import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/services/advice.service.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/components/loading.component.dart';

class AdvicesPage extends StatefulWidget {
  const AdvicesPage({Key? key}) : super(key: key);

  @override
  State<AdvicesPage> createState() => _AdvicesPageState();
}

class _AdvicesPageState extends State<AdvicesPage> {
  AdviceSet? onGoingAdvice;
  bool isLoaded = false;
  var trainerService = locator<TrainerAgentService>();
  var workoutService = locator<WorkoutService>();
  var adviceService = locator<AdviceService>();
  String resp = "";
  @override
  void initState() {
    setUpUi();
    super.initState();
  }

  setUpUi() async {
    var advices = adviceService.fetchAllAdvices();
    for (var adv in advices) {
      if (adv.type == AdviceStatus.onGoing) {
        onGoingAdvice = adv;
      }
    }
    if (onGoingAdvice == null) {
      int key = await adviceService.createAdvice(
        AdviceSet(
          date: DateTime.now(),
          title: "On Going Advices",
          advices: [],
          type: AdviceStatus.onGoing,
        ),
      );
      onGoingAdvice = adviceService.fetchAdviceByKey(key);
    }
    isLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
      ),
      body: !isLoaded
          ? LoadingPage()
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 14.0.h,
                  horizontal: 12.w,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: SURFACE2,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: SURFACE2,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border(
                                bottom: BorderSide(color: BORDER_SECONDARY),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 14.0.h,
                                horizontal: 14.w,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    onGoingAdvice!.title,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SURFACE,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      minimumSize: Size(30.h, 30.h),
                                      shape: CircleBorder(),
                                    ),
                                    child: Icon(Icons.add, size: 20.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (onGoingAdvice!.advices.isEmpty)
                            SizedBox(height: 100.h, child: empty),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY,
        onPressed: () async {
          resp = await trainerService.getPerformanceSummary(null);
          setState(() {});
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.sp),
      ),
    );
  }
}
