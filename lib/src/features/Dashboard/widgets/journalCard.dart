import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journalBook.model.dart';
import 'package:performance_tracker/services/common.service.dart';

class JournalCard extends StatelessWidget {
  final Journal journal;
  final commonService = locator<CommonService>();

  JournalCard(this.journal, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SURFACE2,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      journal.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      commonService.getDateString(journal.dateOfJournal),
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.h),
                      child: Row(
                        children: [
                          Text(
                            "Lines written",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            journal.journalData.length.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "${journal.dateOfJournal.hour.toString().padLeft(2, '0')}:${journal.dateOfJournal.minute.toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
