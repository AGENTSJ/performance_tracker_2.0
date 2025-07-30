import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/src/components/journey.component.dart';
import 'package:performance_tracker/src/features/Nutrition/pages/nutrition.home.page.dart';
import 'package:performance_tracker/src/features/Workout/pages/training.page.dart';
import 'package:performance_tracker/src/components/bottomBar.dart';
import 'package:performance_tracker/src/features/Dashboard/pages/journey.dashboard.dart';
import 'package:performance_tracker/src/features/Dashboard/pages/profile.page.dart';

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
    return ScreenUtilInit(
      designSize: Size(360, 690), // <- your reference design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: PRIMARY,
          scaffoldBackgroundColor: BACKGROUND,
          textTheme: ThemeData.light().textTheme.copyWith(
            bodyLarge: TextStyle(color: TEXT_PRIMARY),
            bodyMedium: TextStyle(color: TEXT_PRIMARY),
          ),
        ),
        home: MainAppEntry(),
      ),
    );
  }
}

class MainAppEntry extends StatefulWidget {
  const MainAppEntry({super.key});

  @override
  State<MainAppEntry> createState() => _MainAppEntryState();
}

class _MainAppEntryState extends State<MainAppEntry> {
  int selectedIndex = 0;

  NutritionModule? nutritionModule;
  TrainingModulePage? trainingModulePage;
  ProfilePageModule? profilePageModule;
  ActivityPage? activityPage;

  @override
  void initState() {
    super.initState();
  }

  _handleIndexChange(int index) {
    if (index > 3) {
      return;
    }
    selectedIndex = index;
    setState(() {});
  }

  getCurrentPage() {
    switch (selectedIndex) {
      case 0:
        nutritionModule ??= NutritionModule();
        return nutritionModule;
      case 1:
        trainingModulePage ??= TrainingModulePage();
        return trainingModulePage;
      case 2:
        activityPage ??= ActivityPage();
        return activityPage;
      case 3:
        profilePageModule ??= ProfilePageModule();
        return profilePageModule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getCurrentPage(),
      bottomNavigationBar: BottomBar(onIndexChange: _handleIndexChange),
    );
  }
}
