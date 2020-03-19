import 'package:flutter/material.dart';

import 'package:questions/course.dart';
import 'package:questions/dashboard/course_item.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: ListView(children: [buildCourseList(), buildAddButton()]),
      );

  Widget buildCourseList() => FutureBuilder(
      future: Storage.getCourses(),
      builder: (_, snapshot) {
        List<Course> courses = [];
        if (snapshot.hasData) courses.addAll(snapshot.data);
        return ListView.builder(
          itemBuilder: (_, i) => CourseItem(courses[i], Colors.tealAccent),
          shrinkWrap: true,
          itemCount: courses.length,
        );
      });

  Widget buildAddButton() => Padding(
      padding: const EdgeInsets.all(8),
      child: RaisedButton(
        child: const Icon(Icons.add, size: 32),
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: CircleBorder(),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CourseWidget(Course())),
        ),
      ));
}