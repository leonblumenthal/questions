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
      body: FutureBuilder<List<Course>>(
        future: coursesFuture,
        builder: (_, snapshot) {
          if (snapshot.hasData) return buildCourseList(snapshot.data);
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget buildCourseList(List<Course> courses) => ListView.builder(
        padding: const EdgeInsets.all(4),
        itemBuilder: (context, i) => buildCourseWidget(courses[i]),
        itemCount: courses.length,
      );

  Widget buildCourseWidget(Course course) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => goToCourse(course),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  course.title,
                  style: const TextStyle(fontSize: 18),
                ),
                RaisedButton(
                  child: Text('Answer'),
                  color: Colors.tealAccent.shade200,
                  colorBrightness: Brightness.dark,
                  onPressed: null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                )
              ],
            ),
          ),
        ),
      );

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
