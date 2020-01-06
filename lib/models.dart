// models for data

class Course {
  int id;
  String title;

  Course({this.id, this.title});

  Course.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
      };

  @override
  String toString() => 'Course $id: $title';
}

class Section {
  int id;
  String title;
  int courseId;

  Section({this.id, this.title, this.courseId});

  Section.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    courseId = map['courseId'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'courseId': courseId,
      };

  @override
  String toString() => 'Section $id: $title';
}

class Question {
  int id;
  String text;

  /// correct consecutive answers.
  int streak;

  /// date of last answer
  DateTime lastAnswered;

  int sectionId;

  Question({
    this.id,
    this.text,
    this.streak = 0,
    this.lastAnswered,
    this.sectionId,
  });

  Question.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    text = map['text'];
    streak = map['streak'];
    lastAnswered = _fromMillisToDateTime(map['lastAnswered']);
    sectionId = map['sectionId'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'streak': streak,
        'lastAnswered': lastAnswered?.millisecondsSinceEpoch,
        'sectionId': sectionId,
      };

  @override
  String toString() => 'Question $id: $text';
}

DateTime _fromMillisToDateTime(millis) =>
    millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);

// model for answering

class QuestionToAnswer {
  Course course;
  Section section;
  Question question;
  QuestionToAnswer(this.course, this.section, this.question);
}

// models for importing

class Importable {
  bool override;
  bool import;
}

class CourseImport with Importable {
  final Course course;
  final List<SectionImport> sectionImports = [];
  CourseImport(this.course);
}

class SectionImport with Importable {
  final Section section;
  final CourseImport courseImport;
  final List<QuestionImport> questionImports = [];
  SectionImport(this.section, this.courseImport);
}

class QuestionImport with Importable {
  final Question question;
  final SectionImport sectionImport;
  QuestionImport(this.question, this.sectionImport);
}
