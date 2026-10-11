import 'package:flutter/foundation.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';
import 'package:performance_tracker/src/features/Journal/models/journalPageStyle.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:performance_tracker/src/features/Journal/repositories/journal.repository.dart';
import 'package:performance_tracker/core/services/ai.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';

class JournalService {
  static const _keyPageStyle = 'journalPageStyle';
  final _jBookRepo = locator<JournalRepository>();
  final _aiService = locator<AiService>();

  /// Paper + ink colours used for every page of the diary.
  final ValueNotifier<JournalPageStyle> pageStyle = ValueNotifier(
    JournalPageStyle.ivory,
  );

  Future<void> loadPageStyle() async {
    final prefs = await SharedPreferences.getInstance();
    pageStyle.value = JournalPageStyle.byId(prefs.getString(_keyPageStyle));
  }

  Future<void> setPageStyle(JournalPageStyle style) async {
    pageStyle.value = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPageStyle, style.id);
  }

  JournalBook? getJournalBook() {
    return _jBookRepo.getJournal();
  }

  createJournalBook(JournalBook book) {
    return _jBookRepo.createJournalBook(book);
  }

  /// All entries ordered oldest -> newest, i.e. the order of the pages in the book.
  List<Journal> getEntriesChronological() {
    var entries = [...?getJournalBook()?.journals];
    entries.sort((a, b) => a.dateOfJournal.compareTo(b.dateOfJournal));
    return entries;
  }

  /// First entry written on the same calendar day as [day], if any.
  Journal? getEntryForDay(DateTime day) {
    for (var entry in getEntriesChronological()) {
      if (isSameDay(entry.dateOfJournal, day)) {
        return entry;
      }
    }
    return null;
  }

  /// Returns the entry for [day], creating an empty one if that day has none yet.
  Future<Journal?> getOrCreateEntryForDay(DateTime day) async {
    var existing = getEntryForDay(day);
    if (existing != null) {
      return existing;
    }
    if (getJournalBook() == null) {
      return null;
    }
    // Stamp the chosen day with the current time of writing.
    var now = DateTime.now();
    var date = DateTime(day.year, day.month, day.day, now.hour, now.minute);
    var entry = Journal(date, "", [], "", null, 0);
    await addJournal(entry, "");
    return entry;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> addJournal(Journal jorunal, String password) async {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    book.journals.add(jorunal);
    await _jBookRepo.updateJournalBook(book.key, book);
  }

  Future<void> removeJournal(Journal journal) async {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    book.journals.remove(journal);
    await _jBookRepo.updateJournalBook(book.key, book);
  }

  Future<void> updateJournal(Journal journal) async {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    await _jBookRepo.updateJournalBook(book.key, book);
  }

  Future<String> beautifyJournal(Journal journal) async {
    var resp = await _aiService.getResponse2(
      AiChatContent(
        system_instruction: AiChatSegment(
          role: null,
          parts: [
            ChatPart(
              text:
                  "You are a formatter you should format the given text to make use of markdown features and make it attractive DO NOT ADD EXTRA CONTENT",
            ),
          ],
        ),
        contents: [
          AiChatSegment(
            role: null,
            parts: [ChatPart(text: journal.journalData)],
          ),
        ],
      ),
    );
    if (resp.success) {
      return resp.message;
    }
    return "";
  }

  Future<void> updatePassword(String password) async {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    book.password = password;
    await _jBookRepo.updateJournalBook(book.key, book);
  }
}
