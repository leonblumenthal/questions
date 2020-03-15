import 'package:flutter/material.dart';
import 'package:questions/answer.dart';
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
        title: const Text('Questions'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    course.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                buildAnswerButton(course)
              ],
            ),
          ),
        ),
      );

  Widget buildAnswerButton(Course course) =>
      FutureBuilder<List<QuestionToAnswer>>(
        future: getQuestionsToAnswer(course),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            var qs = snapshot.data;
            if (qs.isNotEmpty) {
              return RaisedButton(
                child: Text('Answer ${qs.length}'),
                padding: const EdgeInsets.all(12),
                color: Colors.tealAccent.shade200,
                colorBrightness: Brightness.dark,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AnswerScreen(qs)),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(64),
                ),
              );
            }
            // No questions to answer.
            return Icon(Icons.check_circle, color: Colors.tealAccent.shade200);
          }
          // Waiting for the future.
          return CircularProgressIndicator();
        },
      );

  Future goToCourse(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CourseWidget(course)),
    );
    reloadCourses();
  }

  /// Get questions to answer and sort them.
  Future<List<QuestionToAnswer>> getQuestionsToAnswer(Course course) async {
    var questions = await Storage.getQuestionsToAnswer(course);
    questions.shuffle();
    questions.sort(compareQuestionsToAnswer);
    return questions;
  }

  /// Compare questions by streak, section and last answered
  int compareQuestionsToAnswer(QuestionToAnswer a, QuestionToAnswer b) {
    int cmp = a.question.streak.compareTo(b.question.streak);
    if (cmp == 0) {
      cmp = a.section.title.compareTo(b.section.title);
      if (cmp == 0) {
        if (a.question.lastAnswered == null) {
          cmp = -1;
        } else if (b.question.lastAnswered == null) {
          cmp = 1;
        } else {
          cmp = a.question.lastAnswered.compareTo(b.question.lastAnswered);
        }
      }
    }
    return cmp;
  }

  void reloadCourses() {
    coursesFuture = Storage.getCourses();
    setState(() {});
  }
}
