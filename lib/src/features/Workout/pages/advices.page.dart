import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/services/advice.service.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/components/loading.component.dart';
import 'package:performance_tracker/src/features/Workout/pages/advice.details.page.dart';

class AdvicesPage extends StatefulWidget {
  const AdvicesPage({super.key});

  @override
  State<AdvicesPage> createState() => _AdvicesPageState();
}

class _AdvicesPageState extends State<AdvicesPage> {
  AdviceSet? onGoingAdvice;
  AdviceSet? notWorked;
  AdviceSet? worked;
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
      if (adv.type == AdviceStatus.notWorked) {
        notWorked = adv;
      }
      if (adv.type == AdviceStatus.worked) {
        worked = adv;
      }
    }
    if (onGoingAdvice == null) {
      int key = await adviceService.createAdvice(
        AdviceSet(
          lastUpdated: DateTime.now(),
          title: "On Going Advices",
          advices: [],
          type: AdviceStatus.onGoing,
        ),
      );
      onGoingAdvice = adviceService.fetchAdviceByKey(key);
    }
    if (worked == null) {
      int key = await adviceService.createAdvice(
        AdviceSet(
          lastUpdated: DateTime.now(),
          title: "Worked",
          advices: [],
          type: AdviceStatus.worked,
        ),
      );
      worked = adviceService.fetchAdviceByKey(key);
    }
    if (notWorked == null) {
      int key = await adviceService.createAdvice(
        AdviceSet(
          lastUpdated: DateTime.now(),
          title: "Not Worked",
          advices: [],
          type: AdviceStatus.notWorked,
        ),
      );
      notWorked = adviceService.fetchAdviceByKey(key);
    }
    isLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: BACKGROUND),
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
                    AdviceSetWidget(
                      adviceSet: onGoingAdvice!,
                      onUpdate: () {
                        setUpUi();
                      },
                    ),
                    SizedBox(height: 20.h),
                    AdviceSetWidget(
                      adviceSet: worked!,
                      onUpdate: () {
                        setUpUi();
                      },
                    ),
                    SizedBox(height: 20.h),
                    AdviceSetWidget(
                      adviceSet: notWorked!,
                      onUpdate: () {
                        setUpUi();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class AdviceSetWidget extends StatefulWidget {
  final AdviceSet adviceSet;
  final Function() onUpdate;
  const AdviceSetWidget({
    super.key,
    required this.adviceSet,
    required this.onUpdate,
  });
  @override
  State<AdviceSetWidget> createState() => _AdviceSetWidgetState();
}

class _AdviceSetWidgetState extends State<AdviceSetWidget> {
  var adviceService = locator<AdviceService>();

  handleAddAdvice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdviceDetailsPage(
          readonly: false,
          adviceSetF: widget.adviceSet,
          advice: null,
          onUpdate: () {
            widget.onUpdate();
          },
        ),
      ),
    );
  }

  handleViewAdvice(Advice adv) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdviceDetailsPage(
          readonly: true,
          adviceSetF: widget.adviceSet,
          advice: adv,
          onUpdate: () {
            widget.onUpdate();
          },
        ),
      ),
    );
  }

  handleRemoveAdvice(Advice adv) async {
    this.widget.adviceSet.advices.remove(adv);
    await adviceService.updateAdvice(widget.adviceSet.key, widget.adviceSet);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: SURFACE2,
              borderRadius: BorderRadius.circular(8.r),
              border: Border(bottom: BorderSide(color: BORDER_SECONDARY)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 14.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.adviceSet.title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: handleAddAdvice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SURFACE,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size(30.h, 30.h),
                      shape: const CircleBorder(),
                    ),
                    child: Icon(Icons.add, size: 20.sp),
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (widget.adviceSet.advices.isEmpty)
            SizedBox(height: 100.h, child: empty)
          else
            ...widget.adviceSet.advices.map(
              (adv) => Material(
                color: SURFACE2,
                borderRadius: BorderRadius.circular(8.r),
                child: InkWell(
                  onTap: () => handleViewAdvice(adv),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0.h,
                      horizontal: 12.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          adv.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () => handleRemoveAdvice(adv),
                          child: Padding(
                            padding: EdgeInsets.all(8.0.r),
                            child: const Icon(Icons.close),
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
    );
  }
}
