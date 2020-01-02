import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:toast/toast.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final Course course;

  QuestionWidget(this.question, this.course);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Question'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteQuestion,
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: resetQuestion,
            )
          ],
        ),
        body: buildQuestionDetail());
  }

  Widget buildQuestionDetail() => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: widget.question.text),
              decoration: const InputDecoration(labelText: 'Question text'),
              style: const TextStyle(fontSize: 18),
              maxLines: 3,
              minLines: 1,
              onChanged: (String text) async {
                widget.question.text = text.trim();
                await Storage.insertQuestion(widget.question);
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            Container(height: 32),
            buildLastAnswered(),
            Container(height: 16),
            Text(widget.course.toString(), style: const TextStyle(fontSize: 16))
          ],
        ),
      );

  Widget buildLastAnswered() {
    String text = 'Not answered';
    if (widget.question.lastAnswered != null) {
      Duration duration =
          DateTime.now().difference(widget.question.lastAnswered);
      int days = duration.inDays;
      String daysString = '$days ' + (days == 1 ? 'day' : 'days');
      text = 'Last answered: $daysString ago\n'
          'Streak: ${widget.question.streak}';
    }
    return Text(text, style: const TextStyle(fontSize: 16));
  }

  Future deleteQuestion() async {
    bool result = await showDialog(
      context: context,
      builder: buildDeleteDialog,
    );
    if (result == true) {
      await Storage.deleteQuestion(widget.question);
      Toast.show('Deleted ${widget.question}', context, duration: 2);
      Navigator.of(context).pop();
    }
  }

  Widget buildDeleteDialog(BuildContext context) => AlertDialog(
        title: const Text('Delete question'),
        content:
            Text('Are you sure that you want to delete ${widget.question} ?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      );

  Future resetQuestion() async {
    bool result = await showDialog(
      context: context,
      builder: buildResetDialog,
    );
    if (result == true) {
      await Storage.insertQuestion(
        widget.question
          ..lastAnswered = null
          ..streak = 0,
      );
      Toast.show('Reset ${widget.question}', context, duration: 2);
      setState(() {});
    }
  }

  Widget buildResetDialog(BuildContext context) => AlertDialog(
        title: const Text('Reset question'),
        content:
            Text('Are you sure that you want to reset ${widget.question} ?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      );
}
