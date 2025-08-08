import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
            AdviceRow(
              adviceTitle: "asdad",
              adviceDesc:
                  "User seems to have not benfited from the chest volume increase lets now try bicep volume increase",
            ),
          ],
        ),
      ),
    );
  }
}

class AdviceRow extends StatefulWidget {
  final String adviceTitle;
  final String adviceDesc;
  const AdviceRow({
    super.key,
    required this.adviceTitle,
    required this.adviceDesc,
  });

  @override
  State<AdviceRow> createState() => _AdviceRowState();
}

class _AdviceRowState extends State<AdviceRow> {
  bool isTaking = false;
  bool isTaken = false;
  bool showContent = false;

  final coachClient = locator<CoachClientMcp>();

  handleTakeAdvice() async {
    try
    {
      isTaking = true;
      refreshState();
      await coachClient.coachAct(widget.adviceDesc);
      isTaken = true;
    }
    catch(e)
    {
      Fluttertoast.showToast(msg: "An error has occur");
    }
    finally
    {
      isTaking = false;
      refreshState();
    }
  }
  refreshState()
  {
    if(!mounted)return;
    setState(() {
    });
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
            padding: EdgeInsets.all(8.0.r),
            child: Column(
              children: [
                SizedBox(
                  height: 30.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.adviceTitle.isEmpty
                            ? "Advice"
                            : widget.adviceTitle,
                      ),
                      if(isTaking)
                      SizedBox(child: SpinKitSpinningLines(color: PRIMARY,size: 30.sp,),),
                      if(!isTaking)
                      TextButton(
                        onPressed: () {
                          handleTakeAdvice();
                        },
                        style: TextButton.styleFrom(backgroundColor: SURFACE),
                        child: Text(isTaken ? "Taken" : "Take"),
                      ),
                    ],
                  ),
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
