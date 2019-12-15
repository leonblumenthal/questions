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
  String toString() => 'Course: $title';
}

class Question {
  int id;
  String text;
  DateTime created;
  int totalTries;
  int correctTries;
  DateTime lastAnswered;
  int courseId;

  Question(
      {this.id,
      this.text,
      this.created,
      this.totalTries,
      this.correctTries,
      this.lastAnswered,
      this.courseId});

  Question.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    text = map['text'];
    created = DateTime.fromMillisecondsSinceEpoch(map['created']);
    totalTries = map['totalTries'];
    correctTries = map['correctTries'];
    lastAnswered = DateTime.fromMillisecondsSinceEpoch(map['lastAnswered']);
    courseId = map['courseId'];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'created': created?.millisecondsSinceEpoch,
        'totalTries': totalTries,
        'correctTries': correctTries,
        'lastAnswered': lastAnswered?.millisecondsSinceEpoch,
        'courseId': courseId,
      };

  @override
  String toString() => 'Question: $id $courseId';
}
