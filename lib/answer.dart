import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';

import 'package:questions/document.dart';
import 'package:questions/question.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

class AnswerScreen extends StatefulWidget {
  final List<QuestionToAnswer> questions;

  AnswerScreen(this.questions);

  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final Map<Section, Future<PdfDocument>> sectionDocumentFutures = {};
  var currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fill map with futures for all section documents.
    for (var q in widget.questions) {
      if (q.question.marker != null) {
        sectionDocumentFutures.putIfAbsent(
          q.section,
          () => PdfDocument.openFile(q.section.documentPath),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: buildAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QuestionCard(widget.questions[currentIndex]),
          buildAnswerRow(),
        ],
      ));

  Widget buildAppBar() => AppBar(
        title: Text(
          'Question ${currentIndex + 1} of ${widget.questions.length}',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) {
                var qta = widget.questions[currentIndex];
                return QuestionWidget(qta.question, qta.section);
              },
            )),
          )
        ],
      );

  Widget buildAnswerRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            buildAnswerButton(false),
            buildLookupButton(),
            buildAnswerButton(true),
          ],
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
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        onPressed: () => answer(correct),
      );

  Widget buildLookupButton() {
    var qta = widget.questions[currentIndex];
    var onPressed;
    if (qta.question.marker != null) {
      onPressed = () async {
        var document = await sectionDocumentFutures[qta.section];
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DocumentScreen(
            widget.questions[currentIndex].section,
            document,
            initialPageOffset: widget.questions[currentIndex].question.marker.y,
            editable: false,
          ),
        ));
      };
    }
    return RaisedButton(
      child: Icon(Icons.location_on, size: 24),
      color: Colors.blue,
      disabledColor: Colors.grey.shade200,
      colorBrightness: Brightness.dark,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(12),
      onPressed: onPressed,
    );
  }

  Future<void> answer(bool correct) async {
    var question = widget.questions[currentIndex].question;

    if (correct) {
      question.streak++;
    } else {
      question.streak = 0;
    }

    await Storage.insert(question..lastAnswered = getDate());
    await Storage.insert(Answer(correct: correct, questionId: question.id));

    currentIndex++;
    if (currentIndex == widget.questions.length) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }
}

class QuestionCard extends StatelessWidget {
  final QuestionToAnswer qta;

  QuestionCard(this.qta);

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(children: [
          Text(qta.course.title, style: const TextStyle(fontSize: 12)),
          Text(
            qta.section.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              qta.question.text,
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Chip(label: Text('${qta.question.streak}')),
          )
        ]),
      ));
}
