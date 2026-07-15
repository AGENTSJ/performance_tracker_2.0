import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final reportService = locator<ReportService>();
  final commonService = locator<CommonService>();
  var selectedType = EntityType.workout;
  List<Report> reports = [];

  // Dark theme to match the app, with wide tables (e.g. the fatigue matrix)
  // made horizontally scrollable so they never overflow the card.
  final markdownConfig = MarkdownConfig.darkConfig.copy(
    configs: [
      TableConfig(
        wrapper: (table) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        ),
      ),
    ],
  );
  ButtonStyle navButtonStyle = TextButton.styleFrom(
    shape: BeveledRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(0),
    ),
  );
  @override
  void initState() {
    setUpUi(EntityType.workout);
    super.initState();
  }

  setUpUi(EntityType tab) {
    var allReports = reportService.fetchAllReports();
    selectedType = tab;
    reports = [];
    for (var report in allReports) {
      if (report.type == selectedType) {
        reports.add(report);
      }
    }
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  handleRemoveReport(Report report) async {
    await reportService.removeReport(report.key);
    reports.remove(report);
    refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: BACKGROUND,
      appBar: AppBar(backgroundColor: BACKGROUND, title: Text('Reports'),scrolledUnderElevation: 0,),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: SURFACE,
              border: Border(bottom: BorderSide(color: BORDER_PRIMARY)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SURFACE,
                        border: Border(
                          bottom: BorderSide(
                            color: selectedType == EntityType.workout
                                ? PRIMARY
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: TextButton(
                        style: navButtonStyle,
                        onPressed: () {
                          setUpUi(EntityType.workout);
                        },
                        child: Text("Workout"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SURFACE,
                        border: Border(
                          bottom: BorderSide(
                            color: selectedType == EntityType.routine
                                ? PRIMARY
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: TextButton(
                        style: navButtonStyle,
                        onPressed: () {
                          setUpUi(EntityType.routine);
                        },
                        child: Text("Routine"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SURFACE,
                        border: Border(
                          bottom: BorderSide(
                            color: selectedType == EntityType.nutrition
                                ? PRIMARY
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: TextButton(
                        style: navButtonStyle,
                        onPressed: () {
                          setUpUi(EntityType.nutrition);
                        },
                        child: Text("Nutrition"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(12.0.w),
                  child: Column(
                    children: [
                      if (reports.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 4.3,
                              ),
                              SizedBox(child: empty),
                              Text(
                                "No reports to show",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...reports.map((report) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: SURFACE2,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: BORDER_SECONDARY,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0.r),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          report.entityName,
                                          style: TextStyle(
                                            color: TEXT_PRIMARY,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            handleRemoveReport(report);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: SURFACE,
                                          ),
                                          child: Text("Remove"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0.w,
                                    vertical: 4.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Generated: ${commonService.getDateString(report.generatedAt)} ${commonService.getTimeString(report.generatedAt)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: TEXT_SECONDARY,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0.w,
                                    vertical: 4.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Last Updated: ${commonService.getDateString(report.entityLastUpdated)} ${commonService.getTimeString(report.generatedAt)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: TEXT_SECONDARY,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0.w,
                                    vertical: 8.h,
                                  ),
                                  child: MarkdownWidget(
                                    data: report.reportData,
                                    shrinkWrap: true,
                                    config: markdownConfig,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PRIMARY,
                                foregroundColor: SURFACE2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.r))
                              ),
                              onPressed: () async {
                                await reportService.clearAllReports();
                                reports = [];
                                setState(() {});
                              },
                              child: Text("Remove All"),
                            ),
                          ),
                        ],
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
