import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/journalBook.model.dart';
import 'package:performance_tracker/repositories/journal.repository.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';

class JournalService {
  final _jBookRepo = locator<JournalRepository>();
  final _aiService = locator<AiService>();

  JournalBook? getJournalBook() {
    return _jBookRepo.getJournal();
  }

  createJournalBook(JournalBook book) {
    return _jBookRepo.createJournalBook(book);
  }

  addJournal(Journal jorunal, String password) {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    book.journals.add(jorunal);
    _jBookRepo.updateJournalBook(book.key, book);
  }

  removeJournal(Journal journal) {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    book.journals.remove(journal);
    _jBookRepo.updateJournalBook(book.key, book);
  }

  updateJournal(Journal journal) {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    _jBookRepo.updateJournalBook(book.key, book);
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

  updatePassword(String password)async
  {
    var book = _jBookRepo.getJournal();
    if (book == null) {
      return;
    }
    book.password = password;
    _jBookRepo.updateJournalBook(book.key, book);
  }
}
