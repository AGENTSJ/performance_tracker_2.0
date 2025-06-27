import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/services/userGoals.service.dart';

class GoalsWidget extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final User user;
  final targetWeight = TextEditingController();
  final targetSteps = TextEditingController();
  final caloricLimit = TextEditingController();
  final userService = locator<UserService>();
  final userGoalService = locator<UserGoalsService>();
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

  GoalsWidget({super.key, required this.user}) {
    updateFormUi(user);
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
                            decoration: getInputDecoration("Target steps"),
                            controller: targetSteps,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: getInputDecoration("Caloric limit"),
                            controller: targetWeight,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: getInputDecoration("Calorie burn"),
                            controller: targetSteps,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
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
                        SizedBox(width: 10,),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _handleUpdate(BuildContext context)async
  {
    user!
      ..userGoals.stepGoal = int.tryParse(targetSteps.text) ?? user.userGoals.stepGoal
      ..userGoals.targetWeight = double.tryParse(targetWeight.text) ?? user.userGoals.targetWeight
      ..userGoals.calorieLimit = double.tryParse(caloricLimit.text) ?? user.userGoals.calorieLimit
      ..userGoals.calorieLimit = double.tryParse(caloricLimit.text) ?? user.userGoals.caloricBurn;
    
    await userService.updateUser(user);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  _handleReset() async
  {
    await userGoalService.resetGoals();
    updateFormUi(user);
  }
  updateFormUi(User user)
  {
    targetWeight.text = user.weight.toString();
    caloricLimit.text = user.userGoals.calorieLimit.toString();
    targetSteps.text = user.userGoals.stepGoal.toString();
  }
}
