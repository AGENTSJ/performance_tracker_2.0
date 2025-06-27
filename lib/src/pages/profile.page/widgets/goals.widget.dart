import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';
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
  final userGoalService = locator<UserGoalsService>();
  bool formChanged = false;

  final elevatedButtonDecor = ElevatedButton.styleFrom(
    backgroundColor: SURFACE,
    elevation: 0,
    minimumSize: Size(double.infinity, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  InputDecoration getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: PRIMARY, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: PRIMARY, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: PRIMARY, width: 1),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(children: [Text('Goals')]),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: getInputDecoration("Target Weight"),
                            controller: targetWeight,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: getInputDecoration("Calorie burn"),
                            controller: caloricBurn,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: getInputDecoration("Target steps"),
                            controller: targetSteps,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Your caloric limit",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            controller: caloricLimit,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: formChanged ? 60 : 0,
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
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _handleReset();
                              },
                              style: elevatedButtonDecor,
                              child: Text('Reset'),
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

  Future<void> _handleUpdate(BuildContext context) async {
    widget.user
      ..userGoals.stepGoal =
          int.tryParse(targetSteps.text) ?? widget.user.userGoals.stepGoal
      ..userGoals.targetWeight =
          double.tryParse(targetWeight.text) ?? widget.user.userGoals.targetWeight
      ..userGoals.caloricBurn = double.tryParse(caloricBurn.text) ??  widget.user.userGoals.caloricBurn;
    userGoalService.setCaloricLimit(widget.user);
    await userService.updateUser(widget.user);
    updateFormUi(widget.user);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    this.formChanged = false;
    setState(() {
      
    });
  }

  Future<void> _handleReset() async {
    await userGoalService.resetGoals();
    setState(() {
      updateFormUi(widget.user);
    });
  }

  void updateFormUi(User user) {
    targetWeight.text = user.userGoals.targetWeight.toString();
    caloricLimit.text = user.userGoals.calorieLimit.round().toString();
    targetSteps.text = user.userGoals.stepGoal.toString();
    caloricBurn.text = user.userGoals.caloricBurn.round().toString();
  }
}
