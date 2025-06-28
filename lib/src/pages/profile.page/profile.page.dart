import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/src/pages/profile.page/widgets/goals.widget.dart';

class ProfilePageModule extends StatefulWidget {
  const ProfilePageModule({Key? key}) : super(key: key);

  @override
  State<ProfilePageModule> createState() => _ProfilePageModuleState();
}

class _ProfilePageModuleState extends State<ProfilePageModule> {
  final _formKey = GlobalKey<FormState>();
  final userService = locator<UserService>();
  final avatarService = locator<AvatarService>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  late Gender _selectedGender = Gender.other;
  bool isUserFormUpdated = false;
  bool ignoreChanges = false;
  User? user;

  _ProfilePageModuleState() {
    Future.microtask(() async {
      user = await userService.getUserData();
      ignoreChanges = true;
      nameController.text = user!.name;
      ageController.text = user!.age.toString();
      heightController.text = user!.height.toString();
      weightController.text = user!.weight.toString();
      _selectedGender = user!.gender;
      ignoreChanges=false;
      isUserFormUpdated = false;
      setState(() {});
    });
  }

  void _saveUserData() async {
    user!
      ..name = nameController.text
      ..age = int.tryParse(ageController.text) ?? user!.age
      ..height = double.tryParse(heightController.text) ?? user!.height
      ..weight = double.tryParse(weightController.text) ?? user!.weight
      ..gender = _selectedGender;
    await userService.updateUser(user!);
    this.isUserFormUpdated = false;
    setState(() {
      
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red,width: 0.5)
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red,width: 1)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: BACKGROUND),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                onChanged: (){
                  if(ignoreChanges) return;
                  isUserFormUpdated = true;
                  setState(() {
                    
                  });
                },
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 100,
                          child: Center(
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 27,
                                  left: 4.5,
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: PRIMARY,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                avatarService.getDefaultAvatar(
                                  width: 100,
                                  height: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: getInputDecoration("Name"),
                          controller: nameController,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (value){
                                     return validateAge(value);
                                    },
                                    decoration: getInputDecoration("Age"),
                                    controller: ageController,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField(
                                    value: _selectedGender,
                                    decoration: getInputDecoration("Gender"),
                                    items: Gender.values.map((gender) {
                                      return DropdownMenuItem(
                                        value: gender,
                                        child: Text(
                                          gender.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (genderVal) {
                                      _selectedGender = genderVal!;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                                    ],
                                    validator: (value) {
                                      return validateHeight(value);
                                    },
                                    decoration: getInputDecoration("Height (Cm)"),
                                    controller: heightController,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                                    ],
                                    validator: (value){
                                      return validateWeight(value);
                                    },
                                    decoration: getInputDecoration("Weight (Kg)"),
                                    controller: weightController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if(isUserFormUpdated)
                        ElevatedButton(
                          onPressed: () {
                            if(_formKey.currentState!.validate())
                            {
                              _saveUserData();
                            }
                            else
                            {
                              Fluttertoast.showToast(msg: "Error in values");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SURFACE,
                            elevation: 0,
                            minimumSize: Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (user != null) GoalsWidget(user: user!),
            ],
          ),
        ),
      ),
    );
  }

  validateAge(String? value)
  {
    int intVal = int.tryParse(value ?? '0') ?? 0;
    if(intVal<=0 || intVal>200)
    {
      return 'Invalid age';
    }
  }
  validateWeight(String? value) {
    double weight = double.tryParse(value ?? '0') ?? 0;
    if (weight < minimumHumanWeightInKg || weight > maximumHumanWeightInKg) {
      return 'Invalid weight';
    }
  }
  validateHeight(String? value)
  {
    double height = double.tryParse(value ?? '0') ?? 0;
    
    if(height<minimumHumanHeightInCm || height> maximumHumanHeightInCm)
    {
      return 'Invalid height';
    }
  }
}
