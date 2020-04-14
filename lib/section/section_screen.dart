import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/constants.dart';
import 'package:questions/document/section_document_screen.dart';
import 'package:questions/models.dart';
import 'package:questions/question/question_screen.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/dialog_utils.dart';
import 'package:questions/utils/utils.dart';
import 'package:questions/widgets/app_bar_text_field.dart';
import 'package:questions/widgets/streak_widget.dart';
import 'package:toast/toast.dart';

class SectionScreen extends StatefulWidget {
  final Section section;
  final Color color;

  SectionScreen(this.section, this.color);

  @override
  _SectionScreenState createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
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
  void dispose() {
    super.dispose();
    documentFuture?.then((doc) => doc.dispose());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          slivers: [
            buildAppBar(),
            if (documentFuture != null) buildDocumentButton(),
            buildQuestionList()
          ],
        ),
        floatingActionButton: hideBeforeSave(FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: addQuestion,
          backgroundColor: widget.color,
        )),
      );

  Widget buildAppBar() => SliverAppBar(
        title: AppBarTextField(
          controller: titleController,
          onSubmitted: (title) async {
            await Storage.insert(widget.section..title = title.trim());
            setState(() {});
          },
        ),
        actions: hideBeforeSave([buildActionMenu()]),
        floating: true,
        snap: true,
        forceElevated: true,
        backgroundColor: widget.color,
      );

  Widget buildDocumentButton() => SliverToBoxAdapter(
        child: FutureBuilder(
          future: documentFuture,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: RaisedButton(
                    child: const Text(
                      'View Document',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: widget.color,
                    onPressed: () => goToDocument(snapshot.data),
                  ));
            }
            return const SizedBox();
          },
        ),
      );

  void goToDocument(PdfDocument document) async {
    var questions = await questionsFuture;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SectionDocumentScreen(
        widget.section,
        document,
        questions,
        widget.color,
      ),
    ));
    reloadQuestions();
  }

  Widget buildQuestionList() => FutureBuilder(
      future: questionsFuture,
      builder: (_, snapshot) {
        List<Question> questions = [];
        if (snapshot.hasData) questions.addAll(snapshot.data);
        return SliverPadding(
          padding: const EdgeInsets.only(top: 6, bottom: 84),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => buildQuestionItem(questions[i], questions),
              childCount: questions.length,
            ),
          ),
        );
      });

  Widget buildActionMenu() {
    return PopupMenuButton(
      onSelected: (MenuAction action) async {
        if (action == MenuAction.delete) deleteSection();
        if (action == MenuAction.import) importDocument();
        if (action == MenuAction.reset) resetQuestions();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(child: Text('Delete section'), value: MenuAction.delete),
        PopupMenuItem(child: Text('Reset questions'), value: MenuAction.reset),
        PopupMenuItem(child: Text('Import document'), value: MenuAction.import),
      ],
    );
  }

  Widget buildQuestionItem(Question question, List<Question> questions) => Card(
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                StreakWidget(question.streak),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (question.marker == null)
                  const Icon(Icons.location_off, size: 16, color: Colors.grey)
              ],
            ),
          ),
          onTap: () => goToQuestion(question),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  void goToQuestion(Question question) async {
    var document;
    if (documentFuture != null) document = await documentFuture;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuestionScreen(
        question,
        widget.section,
        widget.color,
        document,
      ),
    ));
    reloadQuestions();
  }

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
        await File(widget.section.documentPath).delete().catchError((_) {});

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
        ),
      );
    }
    if (result) {
      var file = await importFile();
      if (file != null) {
        // Delete old file if it exists.
        if (widget.section.documentPath != null) {
          await File(widget.section.documentPath).delete().catchError((_) {});
        }
        // Save section and remove all question markers.
        await Storage.insert(widget.section..documentPath = file.path);
        await Storage.removeQuestionMarkers(widget.section);

        Toast.show(
          'Imported ${file.uri.pathSegments.last}',
          context,
          duration: 2,
        );
        documentFuture = PdfDocument.openFile(file.path);
        setState(() {});
      }
    }
  }

  dynamic hideBeforeSave(w) => widget.section.id == null ? null : w;
}
