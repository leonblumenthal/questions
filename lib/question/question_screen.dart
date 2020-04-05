import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/constants.dart';
import 'package:questions/document/document_screen.dart';
import 'package:questions/models.dart';
import 'package:questions/question/question_timeline.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/dialog_utils.dart';
import 'package:toast/toast.dart';

class QuestionScreen extends StatefulWidget {
  final Question question;
  final Section section;
  final Color color;
  final List<Question> questions;
  final PdfDocument document;

  QuestionScreen(this.question, this.section, this.color, [this.document, this.questions]);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Question'),
          backgroundColor: widget.color,
          actions: [
            IconButton(icon: const Icon(Icons.delete), onPressed: delete),
            IconButton(icon: const Icon(Icons.restore), onPressed: reset)
          ],
        ),
        floatingActionButton:
            widget.document != null && widget.question.marker != null
                ? buildFab()
                : null,
        body: ListView(
          padding: Constants.listViewPadding,
          children: [buildTextWidget(), buildTimeLineWidget()],
        ),
      );

  Widget buildFab() => FloatingActionButton(
        child: const Icon(Icons.location_on),
        backgroundColor: widget.color,
        onPressed: () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => DocumentScreen(
            widget.section,
            widget.document,
            widget.color,
            initialPageOffset: widget.question.marker.y,
            questions: widget.questions,
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

  Widget buildTimeLineWidget() => FutureBuilder(
      future: Storage.getAnswers(widget.question),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return QuestionTimeline(widget.question, snapshot.data);
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Not answered')),
          );
        }
        return Container();
      });

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
