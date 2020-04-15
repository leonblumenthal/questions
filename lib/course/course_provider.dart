import 'dart:io';

import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class CourseProvider extends ChangeNotifier {
  final Course course;
  List<Section> sections = [];

  CourseProvider(this.course) {
    reload();
  }

  void reload() async {
    sections = await Storage.getSections(course);
    notifyListeners();
  }

  void setTitle(String title) => Storage.insert(course..title = title);
  void setColor(Color color) async {
    await Storage.insert(course..color = color);
    notifyListeners();
  }

  Future<void> deleteCourse() async {
    // Delete all document for the course.
    for (var section in sections) {
      var path = section.documentPath;
      if (path != null) await File(path).delete().catchError((_) {});
    }
    // Delete course with sections and questions.
    await Storage.delete(course);
  }
}
