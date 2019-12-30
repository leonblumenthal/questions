import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:toast/toast.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;

  QuestionWidget(this.question);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${widget.question.id}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => deleteQuestion(context),
          )
        ],
      ),
    );
  }

  Future deleteQuestion(BuildContext context) async {
    bool result = await showDialog(
      context: context,
      builder: buildDeleteDialog,
    );
    if (result != null && result) {
      await Storage.deleteQuestion(widget.question);
      Toast.show('Deleted ${widget.question}', context, duration: 2);
      Navigator.of(context).pop();
    }
  }

  Widget buildDeleteDialog(BuildContext context) => AlertDialog(
        title: Text('Delete course'),
        content:
            Text('Are you sure that you want to delete ${widget.question} ?'),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      );
}
