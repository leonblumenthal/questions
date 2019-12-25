import 'package:flutter/material.dart';
import 'package:questions/course.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Course>> courses = Storage.getCourses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CourseWidget(Course())),
              );
              // Reload courses list.
              courses = Storage.getCourses();
              setState(() {} );
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: courses,
        builder: (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
          if (snapshot.hasData) {
            List<Course> courses = snapshot.data;
            return ListView.builder(
              itemBuilder: (_, i) => ListTile(title: Text(courses[i].title)),
              itemCount: courses.length,
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
