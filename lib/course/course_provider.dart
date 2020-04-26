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

  void setTitle(String title) async {
    await Storage.insert(course..title = title);
    notifyListeners();
  }

  void setColor(Color color) async {
    await Storage.insert(course..color = color);
    notifyListeners();
  }

  Future<void> deleteCourse() async {
    // Delete all document for the course.
    for (var section in sections) {
      var path = section.document.path;
      if (path != null) await File(path).delete().catchError((_) {});
    }
    // Reorder others courses.
    await Storage.reorder(course);
    // Delete course with sections and questions.
    await Storage.delete(course);
  }
}
