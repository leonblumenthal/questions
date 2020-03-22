import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:toast/toast.dart';

import 'package:questions/document.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

class SectionWidget extends StatefulWidget {
  final Section section;

  SectionWidget(this.section);

  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  final titleController = TextEditingController();
  Future<List<Question>> questionsFuture;
  Future<PdfDocument> documentFuture;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.section.title;
    questionsFuture = Storage.getQuestions(widget.section);

    if (widget.section.documentPath != null) {
      documentFuture = PdfDocument.openFile(widget.section.documentPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      floatingActionButton: hideBeforeSave(FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: addQuestion,
      )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (documentFuture != null)
            FutureBuilder(
              future: documentFuture,
              builder: (_, snapshot) => snapshot.hasData
                  ? buildDocumentButton(snapshot.data)
                  : Container(),
            ),
          FutureBuilder(
            future: questionsFuture,
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                var questions = snapshot.data;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 84),
                  itemBuilder: (_, i) => buildQuestionItem(
                    questions[i],
                    questions,
                  ),
                  itemCount: questions.length,
                  shrinkWrap: true,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    documentFuture?.then((doc) => doc.dispose());
  }

  Widget buildAppBar() => AppBar(
        title: TextField(
          controller: titleController,
          decoration: const InputDecoration(border: InputBorder.none),
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.white,
          autofocus: titleController.text.isEmpty,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (title) async {
            await Storage.insert(widget.section..title = title.trim());
            setState(() {});
          },
        ),
        actions: hideBeforeSave([buildActionMenu()]),
      );

  Widget buildActionMenu() => PopupMenuButton(
        onSelected: (Action action) async {
          switch (action) {
            case Action.delete:
              deleteSection();
              break;
            case Action.import:
              importDocument();
              break;
            case Action.reset:
              resetQuestions();
              break;
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            child: Text('Delete section'),
            value: Action.delete,
          ),
          const PopupMenuItem(
            child: Text('Reset questions'),
            value: Action.reset,
          ),
          const PopupMenuItem(
            child: Text('Import document'),
            value: Action.import,
          ),
        ],
      );

  Widget buildDocumentButton(PdfDocument document) => Padding(
        padding: const EdgeInsets.all(8),
        child: RaisedButton(
            child: const Text(
              'View Document',
              style: const TextStyle(fontSize: 20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            color: Colors.white,
            onPressed: () async {
              var questions = await questionsFuture;
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DocumentScreen(
                  widget.section,
                  document,
                  questions: questions,
                ),
              ));
              reloadQuestions();
            }),
      );

  Widget buildQuestionItem(Question question, List<Question> questions) => Card(
        child: ListTile(
            title: Text(question.text),
            leading: Chip(
              label: Text(question.streak.toString()),
              backgroundColor: Colors.grey.shade200,
            ),
            trailing: question.marker == null
                ? const Icon(Icons.location_off, size: 16)
                : null,
            onTap: () async {
              var document;
              if (documentFuture != null) document = await documentFuture;
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => QuestionWidget(
                  question,
                  widget.section,
                  document,
                  questions,
                ),
              ));
              reloadQuestions();
            }),
      );

  void reloadQuestions() {
    questionsFuture = Storage.getQuestions(widget.section);
    setState(() {});
  }

  Future<void> deleteSection() async {
    bool result = await showDialog(
      context: context,
      builder: boolDialogBuilder(
        'Delete Section',
        'Are you sure that you want to delete ${widget.section} ?',
      ),
    );
    if (result) {
      // Delete document from local directory.
      if (widget.section.documentPath != null)
        await File(widget.section.documentPath).delete();

      await Storage.delete(widget.section);

      Toast.show('Deleted ${widget.section}', context, duration: 2);
      Navigator.of(context).pop();
    }
  }

  Future<void> resetQuestions() async {
    if (widget.section.id != null) {
      bool result = await showDialog(
        context: context,
        builder: boolDialogBuilder(
          'Reset all questions and answers',
          'Are you sure that you want to reset all questions and answers of ${widget.section} ?',
        ),
      );
      if (result) {
        await Storage.resetQuestions(widget.section);

        Toast.show(
          'Reset all questions and answers of ${widget.section}',
          context,
          duration: 2,
        );
        reloadQuestions();
      }
    }
  }

  /// Show dialog to enter new question and save it.
  Future<void> addQuestion() async {
    String questionText = await showDialog(
      context: context,
      builder: stringDialogBuilder('Add Question', positive: 'Add'),
    );
    if (questionText != null && questionText.isNotEmpty) {
      var question = Question(text: questionText, sectionId: widget.section.id);
      await Storage.insert(question);

      Toast.show('Created $question', context, duration: 2);
      reloadQuestions();
    }
  }

  Future<void> importDocument() async {
    var result = true;
    if (widget.section.documentPath != null) {
      result = await showDialog(
          context: context,
          builder: boolDialogBuilder(
            'Import new document',
            'Are you sure that you want to import a new document and '
                'remove all question markers of ${widget.section}?',
          ));
    }
    if (result) {
      var file = await importFile();
      if (file != null) {
        // Delete old file if it exists.
        if (widget.section.documentPath != null) {
          await File(widget.section.documentPath).delete();
        }
        // Save section and remove all question markers.
        await Storage.insert(widget.section..documentPath = file.path);
        await Storage.removeQuestionMarkers(widget.section);

        Toast.show(
          'Imported ${file.uri.pathSegments.last}',
          context,
          duration: 2,
        );
        reloadQuestions();
      }
    }
  }

  dynamic hideBeforeSave(w) => widget.section.id == null ? null : w;
}

/// Actions for popup menu items.
enum Action { delete, import, reset }
