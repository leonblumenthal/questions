import 'package:flutter/material.dart';

import 'package:questions/course.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class CourseList extends StatefulWidget {
  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  var coursesFuture = Storage.getCourses();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Courses')),
        body: FutureBuilder(
          future: coursesFuture,
          builder: (_, snapshot) => snapshot.hasData
              ? buildCourseList(snapshot.data)
              : CircularProgressIndicator(),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => goToCourse(Course()),
        ),
      );

  Widget buildCourseList(List<Course> courses) => ListView.builder(
        padding: const EdgeInsets.all(4),
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text(courses[i].title),
            onTap: () => goToCourse(courses[i]),
          ),
        ),
        itemCount: courses.length,
      );

  Future<void> goToCourse(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseWidget(course)),
    );
    coursesFuture = Storage.getCourses();
    setState(() {});
  }
}
