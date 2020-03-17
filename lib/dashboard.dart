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
  var coursesFuture = Storage.getCourses();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Questions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => goToCourse(Course()),
            )
          ],
        ),
        body: FutureBuilder(
          future: coursesFuture,
          builder: (_, snapshot) {
            if (snapshot.hasData) return buildCourseList(snapshot.data);
            return CircularProgressIndicator();
          },
        ),
      );

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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    course.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                FutureBuilder(
                  future: Storage.getQuestionsToAnswer(course).then(
                    (qs) => qs
                      ..shuffle()
                      ..sort(compareQuestionsToAnswer),
                  ),
                  builder: (_, snapshot) => snapshot.hasData
                      ? buildAnswerButton(snapshot.data)
                      : CircularProgressIndicator(),
                )
              ],
            ),
          ),
        ),
      );

  Widget buildAnswerButton(List<QuestionToAnswer> questions) {
    if (questions.isNotEmpty) {
      return RaisedButton(
        child: Text('Answer ${questions.length}'),
        padding: const EdgeInsets.all(12),
        color: Colors.tealAccent.shade200,
        colorBrightness: Brightness.dark,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AnswerScreen(questions)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
      );
    }
    // No questions to answer.
    return Icon(Icons.check_circle, color: Colors.tealAccent.shade200);
  }

  /// Compare questions by streak, section and last answered
  int compareQuestionsToAnswer(QuestionToAnswer a, QuestionToAnswer b) {
    var cmp = a.question.streak.compareTo(b.question.streak);
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

  Future<void> goToCourse(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseWidget(course)),
    );
    reloadCourses();
  }

  void reloadCourses() {
    coursesFuture = Storage.getCourses();
    setState(() {});
  }
}
