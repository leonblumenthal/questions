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
  String toString() => 'Section $id: $title';
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
    marker = Marker(pageIndex: map['pageIndex'], px: map['px'], py: map['py']);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'streak': streak,
        'lastAnswered': lastAnswered?.millisecondsSinceEpoch,
        'sectionId': sectionId,
        'pageIndex': marker?.pageIndex,
        'px': marker?.px,
        'py': marker?.py,
      };

  @override
  String toString() => 'Question $id: $text';
}

class Marker {
  int pageIndex;
  double px;
  double py;

  Marker({this.pageIndex, this.px, this.py});
}

DateTime _fromMillisToDateTime(millis) =>
    millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
