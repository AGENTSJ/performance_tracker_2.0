import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/advice.model.dart';
import 'package:performance_tracker/services/advice.service.dart';

class AdviceDetailsPage extends StatefulWidget {
  final Advice? advice;
  final AdviceSet onGoingAdvice;
  final bool readonly;
  final Function() onUpdate;
  const AdviceDetailsPage({
    super.key,
    required this.advice,
    required this.onGoingAdvice,
    required this.readonly,
    required this.onUpdate,
  });

  @override
  State<AdviceDetailsPage> createState() => _AdviceDetailsPageState();
}

class _AdviceDetailsPageState extends State<AdviceDetailsPage> {
  final AdviceService adviceService = locator<AdviceService>();
  late final TextEditingController titleController;
  late final TextEditingController statementController;
  late final TextEditingController conditionController;
  bool adviceStateChanged = false;
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.advice?.title);
    statementController = TextEditingController(
      text: widget.advice?.adviceDesc,
    );
    conditionController = TextEditingController(
      text: widget.advice?.conditions,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    statementController.dispose();
    conditionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final title = titleController.text.trim();
    final statement = statementController.text.trim();
    final condition = conditionController.text.trim();

    if (title.isNotEmpty && statement.isNotEmpty && condition.isNotEmpty) {
      widget.onGoingAdvice.advices.add(
        Advice(
          title: title,
          adviceDesc: statement,
          conditions: condition,
          date: DateTime.now(),
        ),
      );
      await adviceService.updateAdvice(
        widget.onGoingAdvice.key,
        widget.onGoingAdvice,
      );
      widget.onUpdate();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final readonly = widget.readonly;

    return Scaffold(
      appBar: AppBar(
        title: Text(readonly ? 'View Advice' : 'Add Advice'),
        backgroundColor: BACKGROUND,
        actions: [
          if (!readonly)
            IconButton(icon: Icon(Icons.check), onPressed: _handleSubmit),
        ],
      ),
      backgroundColor: BACKGROUND,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                        padding: EdgeInsets.all(14.h),
                        child: Row(
                          children: [
                            Text(
                              "Title",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: TextField(
                        controller: titleController,
                        maxLines: null,
                        readOnly: readonly,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: SURFACE,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
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
                        padding: EdgeInsets.all(14.h),
                        child: Row(
                          children: [
                            Text(
                              "Advice",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: TextField(
                        controller: statementController,
                        maxLines: null,
                        readOnly: readonly,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: SURFACE,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
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
                        padding: EdgeInsets.all(14.h),
                        child: Row(
                          children: [
                            Text(
                              "Conditions",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: TextField(
                        controller: conditionController,
                        maxLines: null,
                        readOnly: readonly,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: SURFACE,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!readonly) SizedBox(height: 20),
              if (!readonly)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: SURFACE2,
                          side: BorderSide(color: BORDER_PRIMARY, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.r))
                        ),
                        child: Text('Add'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
