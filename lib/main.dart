import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/db.dart';
// import 'package:performance_tracker/repository/food.repository.dart';
import 'package:performance_tracker/modules/nutritionModule/src/pages/nutritionHome.page/home.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpDependencyInjection();
  await setupHiveDb();
  // var f = locator<FoodRepository>();
  // f.test();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}