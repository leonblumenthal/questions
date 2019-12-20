import 'package:flutter/material.dart';
import 'package:questions/course.dart';
import 'package:questions/models.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CourseWidget(Course())),
            ),
          )
        ],
      ),
    );
  }
}
