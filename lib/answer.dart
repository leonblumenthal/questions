import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

class AnswerScreen extends StatefulWidget {
  final List<Question> questions;

  AnswerScreen(this.questions);

  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Answer ${currentIndex + 1}/${widget.questions.length}'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => QuestionWidget(widget.questions[currentIndex]),
              )),
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            buildQuestionCard(widget.questions[currentIndex]),
            buildAnswerRow()
          ],
        ),
      );

  Widget buildAnswerRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildAnswerButton(false),
            buildAnswerButton(true),
          ],
        ),
      );

  Widget buildQuestionCard(Question question) => Card(
        margin: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: <Widget>[
              Text(
                'Technische Mechanik',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                '10 Freischneiden',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  question.text,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Chip(label: Text('${question.streak}')),
              )
            ],
          ),
        ),
      );

  Widget buildAnswerButton(bool correct) => RaisedButton(
        child: Icon(
          correct ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
          size: 48,
        ),
        color:
            correct ? Colors.tealAccent.shade200 : Colors.pinkAccent.shade200,
        colorBrightness: Brightness.dark,
        shape: CircleBorder(),
        padding: const EdgeInsets.all(12),
        onPressed: () => answer(correct),
      );

  Future answer(bool correct) async {
    Question currentQuestion = widget.questions[currentIndex];
    if (correct) {
      currentQuestion.streak += 1;
    } else {
      currentQuestion.streak = 0;
    }
    // Set last answered to current date.
    currentQuestion.lastAnswered = Utils.getDate();

    await Storage.insertQuestion(currentQuestion);

    currentIndex += 1;

    if (currentIndex == widget.questions.length) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {});
  }
}
