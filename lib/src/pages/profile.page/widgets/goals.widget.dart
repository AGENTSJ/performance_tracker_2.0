import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/services/userGoals.service.dart';

class GoalsWidget extends StatefulWidget {
  final User user;
  const GoalsWidget({super.key, required this.user});
  @override
  State<GoalsWidget> createState() => _GoalsWidgetState();
}

class _GoalsWidgetState extends State<GoalsWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController targetWeight;
  late TextEditingController targetSteps;
  late TextEditingController caloricBurn;
  late TextEditingController caloricLimit;
  final userService = locator<UserService>();
  final dayService  = locator<DayService>();
  final userGoalService = locator<UserGoalsService>();
  bool formChanged = false;

  final elevatedButtonDecor = ElevatedButton.styleFrom(
    backgroundColor: SURFACE,
    elevation: 0,
    minimumSize: Size(double.infinity, 40.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
  );

  InputDecoration getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: CONT_BACKGROUND,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: PRIMARY, width: 0.5.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: PRIMARY, width: 0.5.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: PRIMARY, width: 1.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.red, width: 0.5.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.red, width: 1.w),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    targetWeight = TextEditingController();
    targetSteps = TextEditingController();
    caloricLimit = TextEditingController();
    caloricBurn = TextEditingController();
    updateFormUi(widget.user);
  }

  @override
  void dispose() {
    targetWeight.dispose();
    targetSteps.dispose();
    caloricLimit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CONT_BACKGROUND,
        borderRadius: BorderRadius.circular(8.r),
      ),
      width: double.infinity,
      child: Form(
        onChanged: () {
          setState(() {
            formChanged = true;
          });
        },
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            children: [
              Row(children: [Padding(
                padding: EdgeInsets.only(top:8.0.h,bottom: 8.0.h),
                child: Text('Goals',style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500),),
              )]),
              Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            validator: (value) {
                              return validateWeight(value);
                            },
                            decoration: getInputDecoration("Target Weight"),
                            controller: targetWeight,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: getInputDecoration("Calorie burn"),
                            controller: caloricBurn,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: getInputDecoration("Target steps"),
                            controller: targetSteps,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (!formChanged)
                      Material(
                        color: SURFACE,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: TEXT_PRIMARY,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5
                                ), // default style
                                children: [
                                  TextSpan(text: 'Eat '),
                                  TextSpan(
                                    text:
                                        '${widget.user.userGoals.calorieLimit.round()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ), // bold word
                                  ),
                                  TextSpan(
                                    text: ' and you will reach your goal in ',
                                  ),
                                  TextSpan(
                                    text:
                                        '${userGoalService.getDaysToReachWeightTarget(widget.user)} days',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ), // another bold word
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 10.h),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: formChanged ? 60.h : 0,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _handleUpdate(context);
                              },
                              style: elevatedButtonDecor,
                              child: Text('Update'),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _handleRecommended();
                              },
                              style: elevatedButtonDecor,
                              child: Text('Suggest'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  validateWeight(String? value) {
    double weight = double.tryParse(value ?? '0') ?? 0;
    if (weight < minimumHumanWeightInKg || weight > maximumHumanWeightInKg) {
      return 'Invalid weight';
    }
  }

  Future<void> _handleUpdate(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      widget.user
        ..userGoals.stepGoal =
            int.tryParse(targetSteps.text) ?? widget.user.userGoals.stepGoal
        ..userGoals.targetWeight =
            double.tryParse(targetWeight.text) ??
            widget.user.userGoals.targetWeight
        ..userGoals.caloricChangeGoal =
            double.tryParse(caloricBurn.text) ??
            widget.user.userGoals.caloricChangeGoal;
      userGoalService.setCaloricLimit(widget.user);
      await userService.updateUser(widget.user);
      var currentDay = await dayService.getDayDataByDate(DateTime.now());
      currentDay?.goalForToday = widget.user.userGoals;
      await dayService.updateDayData(currentDay!);
      updateFormUi(widget.user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated successfully!'),showCloseIcon: true,),
      );
      this.formChanged = false;
      setState(() {});
    }
  }

  Future<void> _handleRecommended() async {
    if (_formKey.currentState!.validate()) {
      await userGoalService.resetGoals();
      var currentDay = await dayService.getDayDataByDate(DateTime.now());
      currentDay?.goalForToday = widget.user.userGoals;
      await dayService.updateDayData(currentDay!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated successfully!'),showCloseIcon: true,),
      );
      setState(() {
        updateFormUi(widget.user);
      });
    }
  }

  void updateFormUi(User user) {
    targetWeight.text = user.userGoals.targetWeight.toString();
    caloricLimit.text = user.userGoals.calorieLimit.round().toString();
    targetSteps.text = user.userGoals.stepGoal.toString();
    caloricBurn.text = user.userGoals.caloricChangeGoal.round().toString();
  }
}
