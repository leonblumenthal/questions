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

class Question {
  int id;
  String text;
  DateTime created;
  int totalTries;
  int correctTries;
  DateTime lastAnswered;
  bool correctlyAnswered;
  int courseId;

  Question(
      {this.id,
      this.text,
      this.created,
      this.totalTries = 0,
      this.correctTries = 0,
      this.lastAnswered,
      this.correctlyAnswered = false,
      this.courseId});

  Question.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    text = map['text'];
    created = _fromMillisToDateTime(map['created']);
    totalTries = map['totalTries'];
    correctTries = map['correctTries'];
    lastAnswered = _fromMillisToDateTime(map['lastAnswered']);
    correctlyAnswered = map['correctlyAnswered'] == 1;
    courseId = map['courseId'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'created': created?.millisecondsSinceEpoch,
        'totalTries': totalTries,
        'correctTries': correctTries,
        'lastAnswered': lastAnswered?.millisecondsSinceEpoch,
        'correctlyAnswered': correctlyAnswered ? 1 : 0,
        'courseId': courseId,
      };

  @override
  String toString() => 'Question $id: $text';
}

DateTime _fromMillisToDateTime(millis) =>
    millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
