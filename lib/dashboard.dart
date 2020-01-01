import 'package:flutter/material.dart';
import 'package:questions/course_list.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CourseList()),
            ),
          )
        ],
      ),
      body: Container(),
    );
  }
}
