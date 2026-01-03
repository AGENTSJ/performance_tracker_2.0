import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journalBook.model.dart';
import 'package:performance_tracker/services/jorunal.service.dart';
import 'package:performance_tracker/src/features/Dashboard/pages/journalEntry.page.dart';
import 'package:performance_tracker/src/features/Dashboard/widgets/journalCard.dart';

class JournalPage extends StatefulWidget {
  final String pass;
  const JournalPage({Key? key, required this.pass}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  var journalService = locator<JournalService>();
  List<Journal> journals = [
    // Add your Journal objects here
  ];

  @override
  void initState() {
    setUpJournals();
    super.initState();
  }

  setUpJournals() {
    this.journals = journalService.getJournalBook()?.journals ?? [];
  }

  Future<void> addJournal(String title) async {
    final newJournal = Journal(DateTime.now(), "", [], title, null, 0);
    await journalService.addJournal(newJournal, widget.pass);
    setState(() {});
  }

  void showAddJournalDialog() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add Journal'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Title',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                await addJournal(title);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingPage() {
    var _passContl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18.0.r,
                right: 18.0.r,
                top: 18.0.r,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18.0.r,
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 10),
                      ExpansionTile(
                        title: Text(
                          'Change password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _passContl,
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (_passContl.text.length < 5) {
                                      Fluttertoast.showToast(
                                        msg: "Invalid new password",
                                      );
                                      return;
                                    }
                                    journalService.updatePassword(
                                      _passContl.text,
                                    );
                                    Fluttertoast.showToast(
                                      msg: "Password updated",
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Text("Update"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journals'),
        backgroundColor: BACKGROUND,
        actions: [
          IconButton(
            onPressed: () {
              _showSettingPage();
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      backgroundColor: BACKGROUND,
      body: journals.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                empty,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No journals found !!",
                      style: TextStyle(color: TEXT_TERTIARY, fontSize: 14.sp),
                    ),
                  ],
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: journals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final journal = journals[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JournalEntryPage(journal: journal),
                      ),
                    );
                    setState(() {});
                  },
                  child: JournalCard(journal),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddJournalDialog,
        backgroundColor: PRIMARY,
        child: Icon(Icons.add, color: SURFACE),
      ),
    );
  }
}
