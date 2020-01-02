import 'package:flutter/material.dart';
import 'package:questions/answer.dart';
import 'package:questions/course.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

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
      body: Container(
        child: FutureBuilder(
          future: coursesFuture,
          builder: (_, AsyncSnapshot<List<Course>> snapshot) => snapshot.hasData
              ? GridView.count(
                  crossAxisCount: 2,
                  children: snapshot.data.map(buildCourse).toList(),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget buildCourse(Course course) => FutureBuilder(
        future: getQuestionsToAnswer(course),
        builder: (_, snapshot) => snapshot.hasData
            ? buildCourseCard(course, snapshot.data)
            : Container(),
      );

  /// Get all questions of the course that should be answered.
  Future<List<Question>> getQuestionsToAnswer(Course course) async {
    List<Question> questions = await Storage.getQuestions(course);
    return questions
        .where((q) =>
            q.streak == 0 ||
            Utils.getDate().difference(q.lastAnswered).inDays >= q.streak)
        .toList();
  }

  Widget buildCourseCard(Course course, List<Question> questions) => Card(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                course.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Divider(height: 0),
            buildAnswerButton(course, questions),
            FlatButton(
              child: const Text('Edit'),
              onPressed: () => goToCourse(course),
            )
          ],
        ),
      );

  Widget buildAnswerButton(Course course, List<Question> questions) => Expanded(
        child: Center(
          child: RaisedButton(
            child: Text(
              questions.length.toString(),
              style: const TextStyle(fontSize: 40),
            ),
            onPressed: questions.isNotEmpty
                ? () async {
                    // Answer questions and reload after returning.
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Answer(questions, course),
                    ));
                    setState(() {});
                  }
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(64),
            ),
            color: Colors.grey.shade100,
            disabledColor: Colors.grey.shade100,
          ),
        ),
      );

  /// Navigate to the course widget and
  /// reload the courses after returning from it.
  Future goToCourse(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CourseWidget(course)),
    );
    coursesFuture = Storage.getCourses();
    setState(() {});
  }
}
