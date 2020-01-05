import 'package:flutter/material.dart';
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteSection,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: resetAllQuestions,
          )
        ],
      ),
      floatingActionButton: widget.section.id == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await addQuestion();
                reloadQuestions();
              },
            ),
      body: buildQuestionsList(),
    );
  }

  Widget buildQuestionsList() => FutureBuilder(
        future: questionsFuture,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            List<Question> questions = snapshot.data;
            return ListView.builder(
              itemBuilder: (_, i) => ListTile(
                leading: Chip(label: Text(questions[i].streak.toString())),
                title: Text(questions[i].text),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => QuestionWidget(questions[i]),
                  ));
                  reloadQuestions();
                },
              ),
              itemCount: questions.length,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );

  void reloadQuestions() {
    questionsFuture = Storage.getQuestions(widget.section);
    setState(() {});
  }

  Future saveTitle(String title) async {
    await Storage.insertSection(widget.section..title = title);
    Toast.show('Saved ${widget.section}', context, duration: 2);
    setState(() {});
  }

  Future deleteSection() async {
    if (widget.section.id != null) {
      bool result = await showDialog(
        context: context,
        builder: Utils.boolDialogBuilder(
          'Delete Section',
          'Are you sure that you want to delete ${widget.section} ?',
        ),
      );
      if (result != null && result) {
        await Storage.deleteSection(widget.section);
        Toast.show('Deleted ${widget.section}', context, duration: 2);
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future resetAllQuestions() async {
    if (widget.section.id != null) {
      bool result = await showDialog(
        context: context,
        builder: Utils.boolDialogBuilder(
          'Reset all questions',
          'Are you sure that you want to reset all questions of ${widget.section} ?',
        ),
      );
      if (result == true) {
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
    }
  }
}
