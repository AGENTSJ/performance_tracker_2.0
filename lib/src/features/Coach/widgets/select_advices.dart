import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Coach/usecases/coach_client_mcp.dart';

class SelectAdviceList extends StatefulWidget {
  const SelectAdviceList({super.key});

  @override
  State<SelectAdviceList> createState() => _SelectAdviceListState();
}

class _SelectAdviceListState extends State<SelectAdviceList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.r),
      child: Container(
        decoration: BoxDecoration(
          color: SURFACE2,
          border: Border.all(color: BORDER_SECONDARY),
          borderRadius: BorderRadius.circular(8.r),
        ),
        width: double.infinity,
        height: 300.h,
        child: Column(
          children: [
            _AdviceRow(
              adviceTitle: "Always be in a 500 cal defict",
              adviceDesc:
                  "Since you are in a clorie defict and your aim is msucle gain you should be no more than 500 cal deficit",
            ),
          ],
        ),
      ),
    );
  }
}

class _AdviceRow extends StatefulWidget {
  final String adviceTitle;
  final String adviceDesc;
  const _AdviceRow({
    super.key,
    required this.adviceTitle,
    required this.adviceDesc,
  });

  @override
  State<_AdviceRow> createState() => __AdviceRowState();
}

class __AdviceRowState extends State<_AdviceRow> {
  bool isTaken = false;
  bool showContent = false;

  final coachClient = locator<CoachClientMcp>();

  handleTakeAdvice() async {
    await coachClient.coachAct(widget.adviceTitle, widget.adviceDesc);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () {
          setState(() {
            showContent = !showContent;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300), // BORDER_PRIMARY
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.adviceTitle.isEmpty
                          ? "Advice"
                          : widget.adviceTitle,
                    ),
                    TextButton(
                      onPressed: () {
                        handleTakeAdvice();
                      },
                      child: Text(isTaken ? "Taken" : "Take"),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: showContent
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(widget.adviceDesc),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
