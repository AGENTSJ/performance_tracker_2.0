import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';

class JournalRepository
{
  final _box = Hive.box<JournalBook>(Collections.journal.value);

  Future<JournalBook?> createJournalBook(JournalBook journalBook)async
  {
    int jbookId = await _box.add(journalBook);
    return getJournalBookById(jbookId);
  }

  JournalBook? getJournal()
  {
    var jorunals = _box.values.toList();
    return jorunals.lastOrNull;
  }

  JournalBook? getJournalBookById(int id)
  {
    return _box.get(id);
  }

  Future<void> updateJournalBook(int id, JournalBook jbook)async
  {
    return await _box.put(id, jbook);
  }
  
}