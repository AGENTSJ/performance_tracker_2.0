import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';
import 'package:performance_tracker/services/user.service.data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final userService = locator<UserService>();
  User? user;

  void _loadUserData() async {
    user =  await userService.getUserData();
    setState(() {
      
    });
  }

  // Simulate saving user data (replace with real data source)
  void _saveUserData() async {
    await userService.updateUser(user!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child:SingleChildScrollView(
            child: Column(
              children: [
                Text(user?.name ?? 'didnt load' ),
                TextFormField(
                  initialValue: user?.name ?? 'didnt load',
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}