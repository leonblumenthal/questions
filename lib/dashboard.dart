import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:questions/answer.dart';
import 'package:questions/course.dart';
import 'package:questions/models.dart';
import 'package:questions/parser.dart';
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
            onPressed: import,
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
          ..sort(
            (a, b) =>
                2 * a.section.title.compareTo(b.section.title) +
                a.question.streak.compareTo(b.question.streak),
          );
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
              child: const Text('Edit'),
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

  Future import() async {
    File file = await FilePicker.getFile();
    if (file == null) return;

    var map = Parser.parse(file.readAsStringSync());

    Parser.parse(file.readAsStringSync()).forEach((course, sections) async {
      await Storage.insertCourse(course);
      map[course].forEach((section, qs) async {
        await Storage.insertSection(section..courseId = course.id);
        qs.forEach(
          (q) => Storage.insertQuestion(q..sectionId = section.id),
        );
      });
    });

    reloadCourses();
  }

  void reloadCourses() {
    coursesFuture = Storage.getCourses();
    setState(() {});
  }
}
