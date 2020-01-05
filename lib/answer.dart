import 'dart:async';

import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

class Answer extends StatefulWidget {
  final List<QuestionToAnswer> questions;

  Answer(this.questions);

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
          children: <Widget>[
            buildQuestionCard(widget.questions[currentIndex]),
            buildAnswerButtons(),
          ],
        ),
      ),
    );
  }

  Future goToQuestion(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuestionWidget(
        widget.questions[currentIndex].question,
      ),
    ));
    Question editedQuestion = await Storage.getQuestion(
      widget.questions[currentIndex].question.id,
    );

    if (editedQuestion == null) {
      // Question was probably deleted.
      currentIndex++;
    } else {
      // Reload page with probably new question text.
      widget.questions[currentIndex].question = editedQuestion;
    }
    setState(() {});
  }

  Widget buildQuestionCard(QuestionToAnswer question) => Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Text(
                    question.course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    question.section.title,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              child: Text(
                question.question.text,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            buildStreakWidget(question.question.streak),
          ],
        ),
      );

  Widget buildAnswerButtons() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[buildButton(false), buildButton(true)],
        ),
      );

  Widget buildButton(bool correct) => RaisedButton(
        child: Icon(
            correct
                ? Icons.sentiment_very_satisfied
                : Icons.sentiment_very_dissatisfied,
            size: 40),
        color: correct ? Colors.tealAccent : Colors.pinkAccent,
        colorBrightness: Brightness.dark,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        onPressed: answer(correct),
      );

  Function answer(bool answeredCorrectly) => () async {
        Question question = widget.questions[currentIndex].question;
        // Update question based on answer.
        await Storage.insertQuestion(
          question
            ..lastAnswered = answeredCorrectly ? Utils.getDate() : null
            ..streak = answeredCorrectly ? question.streak + 1 : 0,
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

  Widget buildStreakWidget(int streak) => Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Chip(label: Text(streak.toString())),
        ),
      );
}
