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
  int markerId;

  Question(
      {this.id,
      this.text,
      this.streak = 0,
      this.lastAnswered,
      this.sectionId,
      this.markerId});

  Question.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    text = map['text'];
    streak = map['streak'];
    lastAnswered = _fromMillisToDateTime(map['lastAnswered']);
    sectionId = map['sectionId'];
    markerId = map['markerId'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'streak': streak,
        'lastAnswered': lastAnswered?.millisecondsSinceEpoch,
        'sectionId': sectionId,
        'markerId': markerId,
      };

  @override
  String toString() => 'Question $id: $text';
}

class Reference {
  int id;
  String title;
  String path;
  DateTime added;
  int courseId;

  Reference({this.id, this.title, this.path, this.courseId}) {
    added = DateTime.now();
  }

  Reference.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    path = map['path'];
    added = _fromMillisToDateTime(map['added']);
    courseId = map['courseId'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'path': path,
        'added': added?.millisecondsSinceEpoch,
        'courseId': courseId,
      };

  @override
  String toString() => 'Reference $id: $title';
}

class Marker {
  int id;
  int pageIndex;
  double px;
  double py;
  int referenceId;

  Marker({this.id, this.pageIndex, this.px, this.py, this.referenceId});

  Marker.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    pageIndex = map['pageIndex'];
    px = map['px'];
    py = map['py'];
    referenceId = map['referenceId'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'pageIndex': pageIndex,
        'px': px,
        'py': py,
        'referenceId': referenceId,
      };

  @override
  String toString() => 'Marker $id: $pageIndex ($px, $py)';
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

class CourseImport {
  final Course course;
  final List<SectionImport> sectionImports = [];
  CourseImport(this.course);
}

class SectionImport {
  final Section section;
  final CourseImport courseImport;
  final List<QuestionImport> questionImports = [];
  SectionImport(this.section, this.courseImport);
}

class QuestionImport {
  final Question question;
  final SectionImport sectionImport;
  QuestionImport(this.question, this.sectionImport);
}
