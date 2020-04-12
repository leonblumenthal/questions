import 'dart:math';

import 'package:flutter/material.dart';
import 'package:questions/storage.dart';

class Course extends StorageModel {
  String title;
  Color color;

  Course({int id, this.title, this.color}) : super(id);

  void fromMap(Map<String, dynamic> map) {
    title = map['title'];
    if (map['color'] != null) color = Color(map['color']);
  }

  Map<String, dynamic> toMap() => {'title': title, 'color': color?.value};

  @override
  String toString() => 'Course $title';
}

class Section extends StorageModel {
  String title;
  int courseId;
  String documentPath;

  Section({int id, this.title, this.courseId, this.documentPath}) : super(id);

  fromMap(Map<String, dynamic> map) {
    title = map['title'];
    courseId = map['courseId'];
    documentPath = map['documentPath'];
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'courseId': courseId,
        'documentPath': documentPath,
      };

  @override
  String toString() => 'Section $title';
}

class Question extends StorageModel {
  String text;
  int streak;
  DateTime lastAnswered;
  int sectionId;
  Marker marker;

  Question({
    int id,
    this.text,
    this.streak = 0,
    this.lastAnswered,
    this.sectionId,
    this.marker,
  }) : super(id);

  fromMap(Map<String, dynamic> map) {
    text = map['text'];
    streak = map['streak'];
    lastAnswered = _fromMillisToDateTime(map['lastAnswered']);
    sectionId = map['sectionId'];
    if (map['x'] != null) marker = Marker(map['x'], map['y']);
  }

  Map<String, dynamic> toMap() => {
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

class Answer extends StorageModel {
  bool correct;
  int questionId;
  DateTime dateTime = DateTime.now();

  Answer({this.correct, this.questionId});

  void fromMap(Map<String, dynamic> map) {
    correct = map['correct'] == 1;
    dateTime = DateTime.fromMillisecondsSinceEpoch(map['dateTime']);
    questionId = map['questionId'];
  }

  Map<String, dynamic> toMap() => {
        'correct': correct ? 1 : 0,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'questionId': questionId,
      };
}

DateTime _fromMillisToDateTime(millis) =>
    millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);

class QuestionToAnswer {
  final Question question;
  final Section section;
  final Course course;
  const QuestionToAnswer(this.question, this.section, this.course);
}

class CourseWithStats {
  final Course course;
  final CourseStats stats;

  CourseWithStats(this.course, this.stats);
}

class CourseStats {
  final int sectionCount;
  final int questionCount;
  final double averageStreak;

  CourseStats(this.sectionCount, this.questionCount, this.averageStreak);
}
