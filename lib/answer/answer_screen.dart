import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/answer/question_card.dart';
import 'package:questions/document/document_screen.dart';
import 'package:questions/models.dart';
import 'package:questions/question/question_screen.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/utils.dart';

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
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Question ${currentIndex + 1} of ${widget.questions.length}',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [if (currentIndex > 0) buildUndoButton(), buildEditButton()],
      );

  Widget buildUndoButton() => IconButton(
        icon: const Icon(Icons.undo),
        onPressed: () async {
          currentIndex--;
          var question = widget.questions[currentIndex].question;
          await Storage.undoLastAnswer(question);
          setState(() {});
        },
      );

  Widget buildEditButton() => IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) {
            var qta = widget.questions[currentIndex];
            return QuestionScreen(qta.question, qta.section, qta.course.color);
          },
        )),
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
        child: correct
            ? const Icon(Icons.sentiment_satisfied, size: 48)
            : const Icon(Icons.sentiment_dissatisfied, size: 48),
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
            qta.section.title,
            document,
            qta.course.color,
            pageOffset: qta.question.marker.y,
          ),
        ));
      };
    }
    return RaisedButton(
      child: const Icon(Icons.location_on, size: 24),
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
