import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/usecases/coach_client_mcp.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.data, required this.type});
  final String data;
  final ChatRoles type;
  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  var CHAT_CONT_COLOR = PRIMARY;
  bool showActions = false;
  var coachClient = locator<CoachClientMcp>();

  handleTakeAdvice() {
    if (coachClient.isActing) {
      Fluttertoast.showToast(
        msg: "An another advice is getting applied wait few moments",
      );
      return;
    }
    // Fire and forget: progress is centralised in [CoachClientMcp] and shown
    // on the coach page, so it survives navigating away from this bubble.
    coachClient.coachAct(widget.data);
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            showActions = !showActions;
          });
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: widget.type == ChatRoles.model
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: (widget.type == ChatRoles.model)
                          ? EdgeInsets.only(left: 12.w)
                          : EdgeInsets.only(right: 12.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CHAT_CONT_COLOR,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Column(
                                children: [
                                  MarkdownWidget(
                                    shrinkWrap: true,
                                    data: widget.data,
                                    config: MarkdownConfig.darkConfig,
                                  ),
                                ],
                              ),
                            ),
                            AnimatedSize(
                              duration: Duration(milliseconds: 250),
                              child: !showActions
                                  ? SizedBox.shrink()
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: PRIMARY,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8.r),
                                          bottomRight: Radius.circular(8.r),
                                        ),
                                        border: Border.all(
                                          color: BORDER_PRIMARY,
                                        ),
                                      ),
                                      child: ValueListenableBuilder<CoachActProgress>(
                                        valueListenable: coachClient.actProgress,
                                        builder: (context, progress, _) {
                                          final applyingThis =
                                              progress.isActing &&
                                              progress.adviceDesc == widget.data;
                                          return Row(
                                            children: [
                                              if (applyingThis)
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0.r),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text("Applying… see Coach for progress",style: TextStyle(color: SURFACE2),),
                                                        SizedBox(width: 10.w,),
                                                        SpinKitSpinningLines(
                                                          color: TEXT_TERTIARY,
                                                          size: 30,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              if (!applyingThis)
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () {
                                                      handleTakeAdvice();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadiusGeometry.circular(
                                                              0.r,
                                                            ),
                                                      ),
                                                      backgroundColor: PRIMARY,
                                                      foregroundColor: SURFACE2,
                                                    ),

                                                    child: Text("Take Advice"),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.type == ChatRoles.user)
                      Positioned(
                        right: -7.w,
                        top: -14.h,
                        child: Icon(
                          FontAwesomeIcons.caretDown,
                          size: 50,
                          color: CHAT_CONT_COLOR,
                        ),
                      ),
                    if (widget.type == ChatRoles.model)
                      Positioned(
                        left: -7.w,
                        top: -14.h,
                        child: Icon(
                          FontAwesomeIcons.caretDown,
                          size: 50,
                          color: CHAT_CONT_COLOR,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
