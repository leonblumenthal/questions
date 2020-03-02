import 'package:flutter/material.dart';
import 'package:questions/course.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<Course>> coursesFuture = Storage.getCourses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => goToCourse(Course()),
          )
        ],
      ),
      body: FutureBuilder(
          future: coursesFuture,
          builder: (_, AsyncSnapshot<List<Course>> snapshot) {
            if (snapshot.hasData) {
              List<Course> courses = snapshot.data;
              return ListView.builder(
                itemBuilder: (context, int i) => ListTile(
                  title: Text(courses[i].title),
                  onTap: () => goToCourse(courses[i]),
                ),
                itemCount: courses.length,
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }

  /// Navigate to the course widget and
  /// reload the courses after returning from it.
  Future goToCourse(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CourseWidget(course)),
    );
    reloadCourses();
  }

  void reloadCourses() {
    coursesFuture = Storage.getCourses();
    setState(() {});
  }
}
