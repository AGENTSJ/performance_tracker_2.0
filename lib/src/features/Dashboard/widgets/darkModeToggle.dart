import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/core/services/config.service.dart';

class DarkModeToggle extends StatefulWidget {
  const DarkModeToggle({super.key});

  @override
  State<DarkModeToggle> createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends State<DarkModeToggle> {
  bool isDarkMode = false;
  var config = locator<ConfigService>();
  @override
  void initState() {
    setMode();
    super.initState();
  }

  setMode() async {
    this.isDarkMode = await this.config.isDarkmode();
    setState(() {
      
    });
  }

  toggleDarkMode(bool darkMode) {
    this.isDarkMode = darkMode;
    this.config.setDarkMode(isDarkMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dark mode',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              toggleDarkMode(value);
            },
          ),
        ],
      ),
    );
  }
}
