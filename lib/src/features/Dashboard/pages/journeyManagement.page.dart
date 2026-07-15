import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/journey.service.dart';
import 'package:performance_tracker/src/components/loading.component.dart';

class JourneyManagementPage extends StatefulWidget {
  const JourneyManagementPage({super.key});

  @override
  State<JourneyManagementPage> createState() => _JourneyManagementPageState();
}

class _JourneyManagementPageState extends State<JourneyManagementPage> {
  final journeyService = locator<JourneyService>();
  final commonService = locator<CommonService>();

  Journey? activeJourney;
  List<Journey> previousJourneys = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _setUpUi();
  }

  void _setUpUi() {
    final all = journeyService.getAllJourney();
    activeJourney = journeyService.getActiveJourney();
    previousJourneys = all
        .where((journey) => journey.status != JourneyStatus.onProgress)
        .toList()
      // Most recently started first.
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    isLoaded = true;
    _refreshState();
  }

  void _refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleRemove(Journey journey) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SURFACE2,
        title: const Text("Remove journey"),
        content: const Text(
          "Are you sure you want to remove this journey? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Remove", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (shouldRemove != true) return;
    await journeyService.deleteJourney(journey.key);
    Fluttertoast.showToast(msg: "Journey removed");
    _setUpUi();
  }

  Color _statusColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.onProgress:
        return PRIMARY;
      case JourneyStatus.completed:
        return Colors.green;
      case JourneyStatus.failed:
        return Colors.redAccent;
    }
  }

  String _statusLabel(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.onProgress:
        return "On progress";
      case JourneyStatus.completed:
        return "Completed";
      case JourneyStatus.failed:
        return "Failed";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: const Text("Journey Management"),
        backgroundColor: BACKGROUND,
        scrolledUnderElevation: 0,
      ),
      body: !isLoaded
          ? LoadingPage()
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(14.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Active Journey"),
                    SizedBox(height: 8.h),
                    if (activeJourney == null)
                      _emptyHint("No active journey")
                    else
                      _journeyCard(activeJourney!, removable: false),
                    SizedBox(height: 24.h),
                    _sectionTitle("Previous Journeys"),
                    SizedBox(height: 8.h),
                    if (previousJourneys.isEmpty)
                      _emptyHint("No previous journeys")
                    else
                      ...previousJourneys.map(
                        (journey) => _journeyCard(journey, removable: true),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }

  Widget _emptyHint(String text) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Text(
        text,
        style: TextStyle(color: TEXT_SECONDARY, fontSize: 13.sp),
      ),
    );
  }

  Widget _journeyCard(Journey journey, {required bool removable}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: SURFACE2,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + status chip
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: BORDER_SECONDARY)),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Started ${commonService.getDateString(journey.startDate)}",
                        style: TextStyle(
                          color: TEXT_PRIMARY,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(journey.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _statusLabel(journey.status),
                        style: TextStyle(
                          color: _statusColor(journey.status),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statRow(
                    "Calories changed",
                    "${journey.caloriesChangeAchieved.round()} Cal",
                  ),
                  _statRow("Steps walked", "${journey.stepsWalked}"),
                  if (journey.lastUpdated != null)
                    _statRow(
                      "Last updated",
                      commonService.getDateString(journey.lastUpdated!),
                    ),
                  if (journey.reasonToStop != null &&
                      journey.reasonToStop!.trim().isNotEmpty)
                    _statRow("Reason to stop", journey.reasonToStop!),
                ],
              ),
            ),
            if (removable)
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _handleRemove(journey),
                      style: TextButton.styleFrom(backgroundColor: SURFACE),
                      child: Text(
                        "Remove",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(color: TEXT_SECONDARY, fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: TEXT_PRIMARY,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
