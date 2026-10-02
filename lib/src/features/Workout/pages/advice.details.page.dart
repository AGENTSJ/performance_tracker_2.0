import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Workout/models/advice.model.dart';
import 'package:performance_tracker/src/features/Workout/services/advice.service.dart';

class AdviceDetailsPage extends StatefulWidget {
  final Advice? advice;
  final AdviceSet adviceSetF;
  final bool readonly;
  final Function() onUpdate;
  const AdviceDetailsPage({
    super.key,
    required this.advice,
    required this.adviceSetF,
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
  late AdviceSet adviceSet;
  @override
  void initState() {
    super.initState();
    adviceSet = widget.adviceSetF;
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
      adviceSet.advices.add(
        Advice(
          title: title,
          adviceDesc: statement,
          conditions: condition,
          date: DateTime.now(),
        ),
      );
      await adviceService.updateAdvice(
        adviceSet.key,
        adviceSet,
      );
      widget.onUpdate();
      Navigator.of(context).pop();
    }
  }
  handleStatusChange(AdviceStatus value)async
  {
    if(widget.advice==null)return;

    var valAdviceSet = await adviceService.getAdviceByStatus(value);
    
    adviceSet.advices.remove(widget.advice);
    valAdviceSet.advices.add(widget.advice!);
    await adviceService.updateAdvice(adviceSet.key, adviceSet);      
    await adviceService.updateAdvice(valAdviceSet.key, valAdviceSet);      
    adviceSet = valAdviceSet;
    refreshState();
  }
  refreshState()
  {
    if(mounted) return;
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    final readonly = widget.readonly;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: TEXT_PRIMARY,
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
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: SURFACE2,borderRadius: BorderRadius.circular(8.r)),
                child: Padding(
                  padding: EdgeInsets.all(14.0.r),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Select Status:",
                          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14.sp),

                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<AdviceStatus>(
                            isExpanded: true,
                            hint: Text("Choose",style: TextStyle(color: TEXT_PRIMARY),),
                            value: adviceSet.type,
                            items: AdviceStatus.values.map((status) {
                              return DropdownMenuItem<AdviceStatus>(
                                value: status,
                                child: Text(status.name,style: TextStyle(color: TEXT_PRIMARY),),
                              );
                            }).toList(),
                            onChanged: (value) {
                              handleStatusChange(value!);
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              height: 40,
                            ),
                            menuItemStyleData: const MenuItemStyleData(height: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          backgroundColor: PRIMARY,
                          side: BorderSide(color: BORDER_PRIMARY, width: 1),
                          padding: EdgeInsets.all(12.r),
                          foregroundColor: TEXT_PRIMARY,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(4.r),
                          ),
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
