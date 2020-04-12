import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class DashboardProvider extends ChangeNotifier {
  List<CourseWithStats> _coursesWithStats = [];

  DashboardProvider() {
    reload();
  }

  List<CourseWithStats> get coursesWithStats => _coursesWithStats;

  void reload() async {
    _coursesWithStats = await Storage.getCoursesWithStats();
    notifyListeners();
  }
}
