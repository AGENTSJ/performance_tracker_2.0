import 'package:hive/hive.dart';

part 'journalBook.model.g.dart';

@HiveType(typeId: 32)
class JournalBook extends HiveObject {
  @HiveField(0)
  List<Journal> journals;

  @HiveField(1)
  String password;

  JournalBook(this.journals, this.password);
}

@HiveType(typeId: 33)
class Journal extends HiveObject {
  @HiveField(0)
  DateTime dateOfJournal;

  @HiveField(1)
  String journalData;

  @HiveField(2)
  List<String> imagePaths;
  
  @HiveField(3)
  String title;
  
  @HiveField(4)
  String? backgroundImageUrl;

  @HiveField(5)
  double opacity;
  
  
  Journal(this.dateOfJournal, this.journalData,this.imagePaths,this.title,this.backgroundImageUrl,this.opacity);
}