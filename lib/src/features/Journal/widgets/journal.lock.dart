import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';
import 'package:performance_tracker/src/features/Journal/services/journal.service.dart';
import 'package:performance_tracker/src/features/Journal/pages/journalBook.page.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalTheme.dart';

class JournalLock extends StatefulWidget {
  const JournalLock({Key? key}) : super(key: key);

  @override
  State<JournalLock> createState() => _JournalLockState();
}

class _JournalLockState extends State<JournalLock> {
  JournalBook? book;
  final _jBookService = locator<JournalService>();
  final passController = TextEditingController();
  @override
  void initState() {
    book = _jBookService.getJournalBook();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode the cover ahead of time so it's ready when the diary opens.
    precacheImage(const AssetImage(JournalTheme.coverImage), context);
  }

  handleJournalEntry() async {
    if (passController.value.text.isEmpty ||
        passController.value.text.length < 5) {
      Fluttertoast.showToast(msg: "Minimum password length is 5 ");
      return;
    }
    var pass = passController.text;
    if (book == null) {
      await _jBookService.createJournalBook(JournalBook([], pass));
    } else if (book?.password != pass) {
      Fluttertoast.showToast(msg: "Wrong pass");
      return;
    }
    passController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    if (!mounted) {
      return;
    }
    await Navigator.push(context, _openBookRoute(pass));
    if (mounted) {
      setState(() => book = _jBookService.getJournalBook());
    }
  }

  Route<void> _openBookRoute(String pass) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          JournalBookPage(pass: pass),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: SURFACE2,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: BORDER_SECONDARY)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.0.r),
              child: Row(
                children: [
                  Text(
                    "Journal",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 150.h,
            width: double.infinity,
            child: Center(
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      FontAwesomeIcons.bookOpen,
                      color: TEXT_PRIMARY,
                      size: 40.sp,
                    ),
                  ),
                  Center(
                    child: Icon(
                      FontAwesomeIcons.circle,
                      size: 150.sp,
                      color: PRIMARY,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.all(18.0.r),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          handleJournalEntry();
                        },
                        child: Text(book == null ? "Start" : "Enter"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
