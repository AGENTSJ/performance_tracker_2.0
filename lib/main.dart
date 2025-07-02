import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/src/pages/nutritionHome.page/home.page.dart';
import 'package:performance_tracker/src/pages/training.page/training.page.dart';
import 'package:performance_tracker/src/components/bottomBar.dart';
import 'package:performance_tracker/src/pages/activityPage.dart';
import 'package:performance_tracker/src/pages/profile.page/profile.page.dart';

void main() async {
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
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyLarge: TextStyle(color: TEXT_PRIMARY),
          bodyMedium: TextStyle(color: TEXT_PRIMARY),
        ),
      ),

      home: MainAppEntry(),
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
  int nutritionModuleKey = 0;
  late List<Widget> modules;

  @override
  void initState() {
    super.initState();
    modules = [
      const NutritionModule(),
      const ProfilePageModule(),
      const TrainingModulePage(),
      const ActivityPage(),
    ];
  }

  _handleIndexChange(int index) {
    if (index > modules.length - 1) {
      return;
    }
    selectedIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: modules),
      bottomNavigationBar: BottomBar(onIndexChange: _handleIndexChange),
    );
  }
}
