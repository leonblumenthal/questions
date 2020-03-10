import 'dart:io';
import 'package:flutter/material.dart';
import 'package:questions/document.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';
import 'package:toast/toast.dart';

class SectionWidget extends StatefulWidget {
  final Section section;

  SectionWidget(this.section);

  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  final TextEditingController controller = TextEditingController();
  Future<List<Question>> questionsFuture;

  @override
  void initState() {
    super.initState();
    controller.text = widget.section.title;
    questionsFuture = Storage.getQuestions(widget.section);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          decoration: const InputDecoration(border: InputBorder.none),
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.white,
          autofocus: controller.text.isEmpty,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: saveTitle,
        ),
        actions: hideBeforeSave(
          [
            if (widget.section.documentPath != null)
              IconButton(
                icon: Icon(Icons.library_books),
                onPressed: goToDocument,
              ),
            buildActionMenu(),
          ],
        ),
      ),
      floatingActionButton: hideBeforeSave(
        FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: addQuestion,
        ),
      ),
      body: buildQuestionList(),
    );
  }

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
          PopupMenuItem(
            child: Text('Delete section'),
            value: Action.delete,
          ),
          PopupMenuItem(
            child: Text('Reset questions'),
            value: Action.reset,
          ),
          PopupMenuItem(
            child: Text('Import document'),
            value: Action.import,
          ),
        ],
      );

  Widget buildQuestionList() => FutureBuilder(
        future: questionsFuture,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            List<Question> questions = snapshot.data;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 84),
              itemBuilder: (_, i) => buildQuestionItem(questions[i]),
              itemCount: questions.length,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );

  Widget buildQuestionItem(Question question) => Card(
        child: ListTile(
          title: Text(question.text),
          leading: Chip(
            label: Text(question.streak.toString()),
            backgroundColor: Colors.grey.shade200,
          ),
          trailing: question.marker == null
              ? null
              : Icon(
                  Icons.attach_file,
                  size: 16,
                ),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => QuestionWidget(question),
            ));
            reloadQuestions();
          },
        ),
      );

  void reloadQuestions() {
    questionsFuture = Storage.getQuestions(widget.section);
    setState(() {});
  }

  Future saveTitle(String title) async {
    await Storage.insertSection(widget.section..title = title.trim());
    Toast.show('Saved ${widget.section}', context, duration: 2);
    setState(() {});
  }

  Future deleteSection() async {
    bool result = await showDialog(
      context: context,
      builder: Utils.boolDialogBuilder(
        'Delete Section',
        'Are you sure that you want to delete ${widget.section} ?',
      ),
    );
    if (result) {
      // Delete document from local directory.
      if (widget.section.documentPath != null) {
        await File(widget.section.documentPath).delete();
      }

      await Storage.deleteSection(widget.section);

      Toast.show('Deleted ${widget.section}', context, duration: 2);
      Navigator.of(context).pop();
    }
  }

  Future resetQuestions() async {
    if (widget.section.id != null) {
      bool result = await showDialog(
        context: context,
        builder: Utils.boolDialogBuilder(
          'Reset all questions',
          'Are you sure that you want to reset all questions of ${widget.section} ?',
        ),
      );
      if (result) {
        // TODO: optimize with single query
        for (Question question in await Storage.getQuestions(widget.section)) {
          await Storage.insertQuestion(
            question
              ..lastAnswered = null
              ..streak = 0,
          );
        }
        Toast.show(
          'Reset all questions of ${widget.section}',
          context,
          duration: 2,
        );
        reloadQuestions();
      }
    }
  }

  /// Show dialog to enter new question and save it.
  Future addQuestion() async {
    String questionText = await showDialog(
      context: context,
      builder: Utils.stringDialogBuilder('Add Question', positive: 'Add'),
    );

    if (questionText != null && questionText.isNotEmpty) {
      Question question = Question(
        text: questionText,
        sectionId: widget.section.id,
      );
      await Storage.insertQuestion(question);

      Toast.show('Created $question', context, duration: 2);

      reloadQuestions();
    }
  }

  Future goToDocument() async {
    List<Question> questions = await questionsFuture;
    questions = questions.where((q) => q.marker != null).toList();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentWidget(widget.section, questions),
      ),
    );
    reloadQuestions();
  }

  Future importDocument() async {
    bool result = true;
    if (widget.section.documentPath != null) {
      result = await showDialog(
        context: context,
        builder: Utils.boolDialogBuilder(
          'Import new document',
          'Are you sure that you want to import a new document and '
              'remove all question markers of ${widget.section}?',
        ),
      );
    }
    if (result) {
      File file = await Utils.importFile();
      if (file != null) {
        // Delete old file if it exists.
        if (widget.section.documentPath != null) {
          await File(widget.section.documentPath).delete();
        }
        // Save section and remove all question markers.
        await Storage.insertSection(widget.section..documentPath = file.path);
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

  hideBeforeSave(w) => widget.section.id == null ? null : w;
}

/// Actions for popup menu items.
enum Action { delete, import, reset }
