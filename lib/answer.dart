import 'dart:async';

import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';

class Answer extends StatefulWidget {
  final List<Question> questions;
  final Course course;

  Answer(this.questions, this.course);

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1}/${widget.questions.length}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => goToQuestion(context),
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[buildQuestionCard(), buildAnswerButtons()],
        ),
      ),
    );
  }

  Future goToQuestion(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuestionWidget(
        widget.questions[currentIndex],
        widget.course,
      ),
    ));
    Question editedQuestion = await Storage.getQuestion(
      widget.questions[currentIndex].id,
    );

    if (editedQuestion == null) {
      // Question was probably deleted.
      currentIndex++;
    } else {
      // Reload page with probably new question text.
      widget.questions[currentIndex] = editedQuestion;
    }
    setState(() {});
  }

  Widget buildQuestionCard() => Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.course.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              child: Text(
                widget.questions[currentIndex].text,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );

  Widget buildAnswerButtons() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[buildButton(true), buildButton(false)],
        ),
      );

  Widget buildButton(bool correct) => RaisedButton(
        child: Icon(correct ? Icons.check : Icons.close, size: 40),
        color: correct ? Colors.tealAccent : Colors.pinkAccent,
        colorBrightness: Brightness.dark,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        onPressed: answer(correct),
      );

  Function answer(bool answeredCorrectly) => () async {
        // Update question based on answer.
        await Storage.insertQuestion(
          widget.questions[currentIndex]
            ..lastAnswered = answeredCorrectly ? DateTime.now() : null
            ..streak = answeredCorrectly
                ? widget.questions[currentIndex].streak + 1
                : 0,
        );

        if (currentIndex < widget.questions.length - 1) {
          // Go to nect question.
          currentIndex++;
          setState(() {});
        } else {
          // No questions are left.
          Navigator.of(context).pop();
        }
      };
}
