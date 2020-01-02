import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';
import 'package:toast/toast.dart';

class CourseWidget extends StatefulWidget {
  final Course course;

  CourseWidget(this.course);

  @override
  _CourseWidgetState createState() => _CourseWidgetState();
}

class _CourseWidgetState extends State<CourseWidget> {
  final TextEditingController controller = TextEditingController();
  Future<List<Question>> questionsFuture;

  @override
  void initState() {
    super.initState();
    controller.text = widget.course.title;
    questionsFuture = Storage.getQuestions(widget.course);
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
            onPressed: deleteCourse,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: resetAllQuestions,
          )
        ],
      ),
      floatingActionButton: widget.course.id == null
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
                title: Text(questions[i].text),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => QuestionWidget(questions[i], widget.course),
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
    questionsFuture = Storage.getQuestions(widget.course);
    setState(() {});
  }

  Future saveTitle(String title) async {
    await Storage.insertCourse(widget.course..title = title);
    Toast.show('Saved ${widget.course}', context, duration: 2);
    setState(() {});
  }

  Future deleteCourse() async {
    if (widget.course.id != null) {
      bool result = await showDialog(
        context: context,
        builder: Utils.boolDialogBuilder(
          'Delete course',
          'Are you sure that you want to delete ${widget.course} ?',
        ),
      );
      if (result != null && result) {
        await Storage.deleteCourse(widget.course);
        Toast.show('Deleted ${widget.course}', context, duration: 2);
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future resetAllQuestions() async {
    if (widget.course.id != null) {
      bool result = await showDialog(
        context: context,
        builder: Utils.boolDialogBuilder(
          'Reset all question',
          'Are you sure that you want to reset all questions of ${widget.course} ?',
        ),
      );
      if (result == true) {
        for (Question question in await Storage.getQuestions(widget.course)) {
          await Storage.insertQuestion(
            question
              ..lastAnswered = null
              ..streak = 0,
          );
        }
        Toast.show(
          'Reset all questions of ${widget.course}',
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
      builder: buildQuestionDialog,
    );

    if (questionText != null && questionText.isNotEmpty) {
      Question question = Question(
        text: questionText,
        courseId: widget.course.id,
      );
      await Storage.insertQuestion(question);

      Toast.show('Created $question', context, duration: 2);
    }
  }

  Widget buildQuestionDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return AlertDialog(
      title: const Text('Add Question'),
      content: Container(
        child: TextField(
          controller: controller,
          maxLines: 1,
          style: const TextStyle(fontSize: 16),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        width: 1000,
      ),
      actions: <Widget>[
        FlatButton(
            child: const Text('Cancel'), onPressed: Navigator.of(context).pop),
        FlatButton(
          child: const Text('Add'),
          onPressed: () => Navigator.of(context).pop(controller.text),
        )
      ],
    );
  }
}
