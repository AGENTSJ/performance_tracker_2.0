import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/repositories/dataAdaptation.service.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';
import 'package:performance_tracker/src/components/loading.component.dart';
import 'package:performance_tracker/src/components/goals.widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:performance_tracker/src/features/Workout/pages/workouts.page.dart';

class ProfilePageModule extends StatefulWidget {
  const ProfilePageModule({super.key});
  @override
  State<ProfilePageModule> createState() => _ProfilePageModuleState();
}

class _ProfilePageModuleState extends State<ProfilePageModule> {
  final _formKey = GlobalKey<FormState>();
  final userService = locator<UserService>();
  final avatarService = locator<AvatarService>();
  final dataservice = locator<DataService>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  Gender _selectedGender = Gender.other;
  bool isUserFormUpdated = false;
  bool ignoreChanges = false;
  User? user;
  bool isLoaded = false;
  _ProfilePageModuleState() {
    setUpProfilePageUi();
  }
  setUpProfilePageUi() async {
    user = await userService.getUserData();
    ignoreChanges = true;
    nameController.text = user!.name;
    ageController.text = user!.age.toString();
    heightController.text = user!.height.toString();
    weightController.text = user!.weight.toString();
    _selectedGender = user!.gender;
    ignoreChanges = false;
    isUserFormUpdated = false;
    isLoaded = true;
    await Future.delayed(Duration(milliseconds: WAITING_PERIOD_PAGE_SWITCH_MS));
    setState(() {});
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
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

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
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: BACKGROUND,scrolledUnderElevation: 0,),
      body: !isLoaded
          ? LoadingPage()
          : Padding(
              padding: EdgeInsets.all(16.0.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      onChanged: () {
                        if (ignoreChanges) return;
                        isUserFormUpdated = true;
                        setState(() {});
                      },
                      key: _formKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: CONT_BACKGROUND,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 16.w,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 100.h,
                                child: Center(
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 27.h,
                                        left: 4.5.w,
                                        child: Container(
                                          width: 90.w,
                                          height: 90.h,
                                          decoration: BoxDecoration(
                                            color: PRIMARY,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      if (this.user?.gender ==
                                          Gender.female) ...[
                                        avatarService.getGreetingAvatar(
                                          width: 100.w,
                                          height: 100.h,
                                        ),
                                      ] else ...[
                                        avatarService.getMaleAvatar(
                                          width: 100.w,
                                          height: 100.h,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              TextFormField(
                                decoration: getInputDecoration("Name"),
                                controller: nameController,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 16.h,
                                  bottom: 16.h,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (value) {
                                            return validateAge(value);
                                          },
                                          decoration: getInputDecoration("Age"),
                                          controller: ageController,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: DropdownButtonFormField(
                                          value: _selectedGender,
                                          decoration: getInputDecoration(
                                            "Gender",
                                          ),
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
                                padding: EdgeInsets.only(
                                  top: 16.h,
                                  bottom: 16.h,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
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
                                            return validateHeight(value);
                                          },
                                          decoration: getInputDecoration(
                                            "Height (Cm)",
                                          ),
                                          controller: heightController,
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
                                          validator: (value) {
                                            return validateWeight(value);
                                          },
                                          decoration: getInputDecoration(
                                            "Weight (Kg)",
                                          ),
                                          controller: weightController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isUserFormUpdated)
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _saveUserData();
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Error in values",
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SURFACE,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 40.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text('Save'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    if (user != null) GoalsWidget(user: user!),
                    SizedBox(height: 20.h),
                    Container(
                      decoration: BoxDecoration(
                        color: SURFACE2,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.0.r),
                        child: Column(
                          children: [
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Text(
                                  "Backup",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SURFACE,
                                  ),
                                  onPressed: () {
                                    handleUpload();
                                  },
                                  child: Row(
                                    children: [
                                      Icon(FontAwesomeIcons.download),
                                      SizedBox(width: 10.w),
                                      Text('Import'),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Icon(FontAwesomeIcons.upload),
                                      SizedBox(width: 10.w),
                                      Text('Export'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  handleUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String contents = await file.readAsString();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Container(
              height: 200.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitSpinningLines(color: PRIMARY, size: 60.sp),
                  SizedBox(height: 10.h),
                  Text("Wait a few seconds"),
                ],
              ),
            ),
          ),
        );
        final jsonData = jsonDecode(contents);
        await dataservice.restoreDataFromBackup(jsonData);
        Navigator.of(context).pop();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => WorkoutsPage()));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "An error has occurred.");
    }
  }

  validateAge(String? value) {
    int intVal = int.tryParse(value ?? '0') ?? 0;
    if (intVal <= 0 || intVal > 200) {
      return 'Invalid age';
    }
  }

  validateWeight(String? value) {
    double weight = double.tryParse(value ?? '0') ?? 0;
    if (weight < minimumHumanWeightInKg || weight > maximumHumanWeightInKg) {
      return 'Invalid weight';
    }
  }

  validateHeight(String? value) {
    double height = double.tryParse(value ?? '0') ?? 0;

    if (height < minimumHumanHeightInCm || height > maximumHumanHeightInCm) {
      return 'Invalid height';
    }
  }
}
