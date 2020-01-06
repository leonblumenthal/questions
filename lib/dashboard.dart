import 'package:flutter/material.dart';
import 'package:questions/answer.dart';
import 'package:questions/course.dart';
import 'package:questions/models.dart';
import 'package:questions/import.dart';
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
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: goToImport,
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
  Future<List<QuestionToAnswer>> getQuestionsToAnswer(Course course) async {
    List<Section> sections = await Storage.getSections(course);
    List<QuestionToAnswer> questionsToAnswer = [];
    for (Section section in sections) {
      List<Question> questions = await Storage.getQuestions(section);
      questions.forEach(
        (question) =>
            questionsToAnswer.add(QuestionToAnswer(course, section, question)),
      );
    }

    return questionsToAnswer
        .where((q) =>
            q.question.streak == 0 ||
            Utils.getDate().difference(q.question.lastAnswered).inDays >=
                q.question.streak)
        .toList()
          ..shuffle()
          ..sort(compareQuestionToAnswer);
  }

  /// Sort after:
  /// 1. section title
  /// 2. streak
  /// 3. last answered
  int compareQuestionToAnswer(QuestionToAnswer a, QuestionToAnswer b) {
    int c = a.section.title.compareTo(b.section.title);
    if (c == 0) {
      c = a.question.streak - b.question.streak;
      if (c == 0) {
        if (a.question.lastAnswered == null) {
          c = -1;
        } else if (b.question.lastAnswered == null) {
          c = 1;
        } else {
          c = (a.question.lastAnswered).compareTo(b.question.lastAnswered);
        }
      }
    }
    return c;
  }

  Widget buildCourseCard(Course course, List<QuestionToAnswer> questions) =>
      Card(
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
            buildAnswerButton(questions),
            FlatButton(
              child: const Text(
                'View',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => goToCourse(course),
            )
          ],
        ),
      );

  Widget buildAnswerButton(List<QuestionToAnswer> questions) => Expanded(
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
                      builder: (_) => Answer(questions),
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
    reloadCourses();
  }

  /// Navigate to the import widget and
  /// reload the courses after returning from it.
  Future goToImport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ImportWidget()),
    );

    reloadCourses();
  }

  void reloadCourses() {
    coursesFuture = Storage.getCourses();
    setState(() {});
  }
}
