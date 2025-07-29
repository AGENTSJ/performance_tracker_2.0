import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/components/loading.component.dart';

class AdvicesPage extends StatefulWidget {
  const AdvicesPage({Key? key}) : super(key: key);

  @override
  State<AdvicesPage> createState() => _AdvicesPageState();
}

class _AdvicesPageState extends State<AdvicesPage> {
  List<Advice> advices = [];
  bool isLoaded = false;
  var trainerService = locator<TrainerAgentService>();
  var workoutService = locator<WorkoutService>();
  String resp = "";
  @override
  void initState() {
    isLoaded = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Advices Page'),
      ),
      body: !isLoaded
          ? LoadingPage()
          :
            // advices.isEmpty
            // ? Center(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         SizedBox(height: 100.h, width: double.infinity, child: empty),
            //         SizedBox(height: 20.h),
            //         Text(
            //           "No advices found !!",
            //           style: TextStyle(color: TEXT_PRIMARY, fontSize: 15.sp),
            //         ),
            //       ],
            //     ),
            //   )
            // :
            SingleChildScrollView(child: Column(children: [Text(resp)])),
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
