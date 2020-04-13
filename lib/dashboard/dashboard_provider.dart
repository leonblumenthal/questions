import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class DashboardProvider extends ChangeNotifier {
  List<CourseWithStats> coursesWithStats = [];

  DashboardProvider() {
    reload();
  }

  void reload() async {
    coursesWithStats = await Storage.getCoursesWithStats();
    notifyListeners();
  }
}
