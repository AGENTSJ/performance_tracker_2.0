import 'package:hive/hive.dart';

part 'journalBook.model.g.dart';

@HiveType(typeId: 32)
class JournalBook extends HiveObject {
  @HiveField(0)
  List<Journal> journals;

  @HiveField(1)
  String password;

  JournalBook(this.journals, this.password);

  Map<String, dynamic> toJson() {
    return {
      'journals': journals.map((j) => j.toJson()).toList(),
      'password': password,
    };
  }

  static JournalBook fromJson(Map<String, dynamic> json) {
    return JournalBook(
      (json['journals'] as List<dynamic>)
          .map((e) => Journal.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['password'] as String,
    );
  }
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

  Journal(
    this.dateOfJournal,
    this.journalData,
    this.imagePaths,
    this.title,
    this.backgroundImageUrl,
    this.opacity,
  );
  Map<String, dynamic> toJson() {
    return {
      'dateOfJournal': dateOfJournal.toIso8601String(),
      'journalData': journalData,
      'imagePaths': imagePaths,
      'title': title,
      'backgroundImageUrl': backgroundImageUrl,
      'opacity': opacity,
    };
  }

  static Journal fromJson(Map<String, dynamic> json) {
    return Journal(
      DateTime.parse(json['dateOfJournal'] as String),
      json['journalData'] as String,
      List<String>.from(json['imagePaths'] as List),
      json['title'] as String,
      json['backgroundImageUrl'] as String?,
      (json['opacity'] as num).toDouble(),
    );
  }
}
