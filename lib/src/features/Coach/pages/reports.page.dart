import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Coach/services/report.service.dart';
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
  bool exporting = false;

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
    var _ = reportService.getAndCreateAllWorkoutReports();
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

  showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  handleCopyWorkoutReports() async {
    var export = reportService.buildReportsExport(EntityType.workout);
    if (export.isEmpty) {
      showMessage("No workout reports to copy");
      return;
    }
    await Clipboard.setData(ClipboardData(text: export));
    showMessage("Copied ${reports.length} workout report(s) to clipboard");
  }

  // Exports the raw logged data of the selected tab for the last [weeks]
  // week(s), rather than the reports stored for it.
  handleCopyDataExport(int weeks) async {
    if (exporting) return;
    setState(() {
      exporting = true;
    });
    try {
      var export = selectedType == EntityType.activity
          ? await reportService.buildActivityExport(weeks)
          : await reportService.buildNutritionExport(weeks);
      await Clipboard.setData(ClipboardData(text: export));
      showMessage(
        "Copied last $weeks week(s) of ${selectedType.name} data to clipboard",
      );
    } finally {
      if (mounted) {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  ButtonStyle get actionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: PRIMARY,
    foregroundColor: SURFACE2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
  );

  // The workout tab copies the stored reports themselves, while the nutrition
  // and activity tabs export their raw day by day data for the chosen window.
  Widget buildExportActions() {
    List<Widget> buttons;
    if (selectedType == EntityType.workout) {
      buttons = [
        Expanded(
          child: ElevatedButton(
            style: actionButtonStyle,
            onPressed: handleCopyWorkoutReports,
            child: Text("Copy Workout Reports"),
          ),
        ),
      ];
    } else if (selectedType == EntityType.nutrition ||
        selectedType == EntityType.activity) {
      buttons = [
        Expanded(child: buildDataExportButton(1, "Last 1 Week")),
        SizedBox(width: 8.w),
        Expanded(child: buildDataExportButton(2, "Last 2 Weeks")),
      ];
    } else {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(children: buttons),
    );
  }

  Widget buildDataExportButton(int weeks, String label) {
    return ElevatedButton(
      style: actionButtonStyle,
      onPressed: exporting ? null : () => handleCopyDataExport(weeks),
      child: Text(exporting ? "Exporting..." : label),
    );
  }

  Widget buildTabButton(EntityType type, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.0.w),
      child: Container(
        decoration: BoxDecoration(
          color: SURFACE,
          border: Border(
            bottom: BorderSide(
              color: selectedType == type ? PRIMARY : Colors.transparent,
            ),
          ),
        ),
        child: TextButton(
          style: navButtonStyle,
          onPressed: () {
            setUpUi(type);
          },
          child: Text(label, style: TextStyle(color: TEXT_PRIMARY)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: BACKGROUND,
      appBar: AppBar(backgroundColor: BACKGROUND, title: Text('Reports'),scrolledUnderElevation: 0,foregroundColor: TEXT_PRIMARY,),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: SURFACE,
              border: Border(bottom: BorderSide(color: BORDER_PRIMARY)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              // Scrollable so the tabs never overflow on narrow screens.
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildTabButton(EntityType.workout, "Workout"),
                    buildTabButton(EntityType.routine, "Routine"),
                    buildTabButton(EntityType.nutrition, "Nutrition"),
                    buildTabButton(EntityType.activity, "Activity"),
                  ],
                ),
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
                      buildExportActions(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: actionButtonStyle,
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
