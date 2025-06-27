import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/nutritionHome.page/home.page.dart';
import 'package:performance_tracker/src/pages/profile.page/profile.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpDependencyInjection();
  await setupHiveDb();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: PRIMARY,
        scaffoldBackgroundColor: BACKGROUND,
      ),
      initialRoute: '/',
      routes: {
        '/':(context)=>HomePage(),
        '/profile':(context)=>ProfilePage()
      },
    );
  }
}