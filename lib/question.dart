import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:toast/toast.dart';

import 'package:questions/document.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final Section section;
  final PdfDocument document;

  QuestionWidget(this.question, this.section, [this.document]);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Question'),
          actions: [
            IconButton(icon: const Icon(Icons.delete), onPressed: delete),
            IconButton(icon: const Icon(Icons.restore), onPressed: reset)
          ],
        ),
        floatingActionButton:
            widget.question.marker != null ? buildFab() : null,
        body: ListView(
          children: [buildTextWidget()],
        ),
      );

  Widget buildFab() => FloatingActionButton(
        child: const Icon(Icons.location_on),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DocumentScreen(
            widget.section,
            widget.document,
            initialPageOffset: widget.question.marker.y,
          ),
        )),
      );

  Widget buildTextWidget() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: TextEditingController(text: widget.question.text),
            decoration: const InputDecoration(labelText: 'Question text'),
            style: const TextStyle(fontSize: 18),
            maxLines: 3,
            minLines: 1,
            onChanged: (text) =>
                Storage.insert(widget.question..text = text.trim()),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      );

  Future<void> delete() async {
    bool result = await showDialog(
      context: context,
      builder: boolDialogBuilder(
        'Delete question',
        'Are you sure that you want to delete ${widget.question} ?',
      ),
    );
    if (result) {
      await Storage.delete(widget.question);
      Toast.show('Deleted ${widget.question}', context, duration: 2);
      Navigator.of(context).pop(false);
    }
  }

  Future<void> reset() async {
    bool result = await showDialog(
      context: context,
      builder: boolDialogBuilder(
        'Reset question with answers',
        'Are you sure that you want to reset ${widget.question} with answers ?',
      ),
    );
    if (result) {
      widget.question
        ..lastAnswered = null
        ..streak = 0;
      await Storage.insert(widget.question);
      await Storage.deleteAnswers(widget.question);
      Toast.show('Reset ${widget.question} with answers', context, duration: 2);
      setState(() {});
    }
  }
}
