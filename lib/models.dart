import 'dart:math';

class Course {
  int id;
  String title;

  Course({this.id, this.title});

  Course.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
  }

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  @override
  String toString() => 'Course $title';
}

class Section {
  int id;
  String title;
  int courseId;
  String documentPath;

  Section({this.id, this.title, this.courseId, this.documentPath});

  Section.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    courseId = map['courseId'];
    documentPath = map['documentPath'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'courseId': courseId,
        'documentPath': documentPath,
      };

  @override
  String toString() => 'Section $title';
}

class Question {
  int id;
  String text;
  int streak;
  DateTime lastAnswered;
  int sectionId;
  Marker marker;

  Question({
    this.id,
    this.text,
    this.streak = 0,
    this.lastAnswered,
    this.sectionId,
    this.marker,
  });

  Question.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    text = map['text'];
    streak = map['streak'];
    lastAnswered = _fromMillisToDateTime(map['lastAnswered']);
    sectionId = map['sectionId'];
    if (map['x'] != null) marker = Marker(map['x'], map['y']);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'streak': streak,
        'lastAnswered': lastAnswered?.millisecondsSinceEpoch,
        'sectionId': sectionId,
        'x': marker?.x,
        'y': marker?.y,
      };

  @override
  String toString() => 'Question $text';
}

class Marker extends Point<double> {
  int get pageIndex => y.toInt();
  Marker(double x, double y) : super(x, y);
}

DateTime _fromMillisToDateTime(millis) =>
    millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);

class QuestionToAnswer {
  final Question question;
  final Section section;
  final Course course;
  const QuestionToAnswer(this.question, this.section, this.course);
}
