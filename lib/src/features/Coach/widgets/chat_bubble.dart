import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.data, required this.type});
  final String data;
  final ChatRoles type;
  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  var CHAT_CONT_COLOR = PRIMARY;
  // var CHAT_CONT_COLOR =const Color.fromARGB(255, 130, 218, 147) ;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.type == ChatRoles.model
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Padding(
              padding: (widget.type == ChatRoles.model)
                  ? EdgeInsets.only(right: 12.w)
                  : EdgeInsets.only(left: 12.w),
              child: Container(
                decoration: BoxDecoration(
                  color: CHAT_CONT_COLOR,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    children: [
                      MarkdownWidget(
                        shrinkWrap: true,
                        data: widget.data,
                        config: MarkdownConfig.darkConfig
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.type == ChatRoles.model)
              Positioned(
                right: -7.w,
                top: -14.h,
                child: Icon(
                  FontAwesomeIcons.caretDown,
                  size: 50,
                  color: CHAT_CONT_COLOR,
                ),
              ),
            if (widget.type == ChatRoles.user)
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
    );
  }
}
