import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/storage.dart';

class Course extends StorageModel {
  String title;
  Color color;
  int order;

  Course({int id, this.title, this.color, this.order}) : super(id);

  void fromMap(Map<String, dynamic> map) {
    title = map['title'];
    if (map['color'] != null) color = Color(map['color']);
    order = map['order'];
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'color': color?.value,
        'order': order,
      };

  @override
  String toString() => 'Course $title';
}

class Section extends StorageModel {
  String title;
  int order;
  Document document;
  int courseId;

  Section({int id, this.title, this.order, this.document, this.courseId})
      : super(id);

  fromMap(Map<String, dynamic> map) {
    title = map['title'];
    order = map['order'];
    if (map['documentPath'] != null) {
      document =
          Document(map['documentPath'], map['startOffset'], map['endOffset']);
    }
    courseId = map['courseId'];
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'order': order,
        'documentPath': document?.path,
        'startOffset': document?.startOffset,
        'endOffset': document?.endOffset,
        'courseId': courseId,
      };

  @override
  String toString() => 'Section $title';
}

class Document {
  String path;
  int startOffset;
  int endOffset;

  Document(this.path, [this.startOffset = 0, this.endOffset = -1]);
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
  final int _sectionCount;
  final int _questionCount;
  final double _averageStreak;

  CourseStats(this._sectionCount, this._questionCount, this._averageStreak);

  String get sectionCount => _sectionCount.toString();
  String get questionCount => _questionCount.toString();
  String get averageStreak => _averageStreak?.toStringAsFixed(1);
}

class PdfDocumentWrapper {
  final PdfDocument pdfDocument;
  final int startOffset;
  final int endOffset;

  PdfDocumentWrapper(
    this.pdfDocument, [
    this.startOffset = 0,
    this.endOffset = -1,
  ]);

  PdfDocumentWrapper.fromDocument(this.pdfDocument, Document document)
      : startOffset = document.startOffset,
        endOffset = document.endOffset;

  int get pageCount {
    if (endOffset == -1) return pdfDocument.pageCount - startOffset;
    return endOffset - startOffset;
  }
}
