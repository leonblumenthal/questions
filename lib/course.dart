import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';
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
          onSubmitted: (String title) => saveTitle(title, context),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => deleteCourse(context),
          )
        ],
      ),
      floatingActionButton: widget.course.id == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await addQuestion(context);
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

  Future saveTitle(String title, BuildContext context) async {
    await Storage.insertCourse(widget.course..title = title);
    Toast.show('Saved ${widget.course}', context, duration: 2);
    setState(() {});
  }

  Future deleteCourse(BuildContext context) async {
    if (widget.course.id != null) {
      bool result = await showDialog(
        context: context,
        builder: buildDeleteDialog,
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

  Widget buildDeleteDialog(BuildContext context) => AlertDialog(
        title: const Text('Delete course'),
        content:
            Text('Are you sure that you want to delete ${widget.course} ?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      );

  /// Show dialog to enter new question and save it.
  Future addQuestion(BuildContext context) async {
    String questionText = await showDialog(
      context: context,
      builder: buildQuestionDialog,
    );

    if (questionText != null && questionText.isNotEmpty) {
      Question question = Question(
        text: questionText,
        courseId: widget.course.id,
        created: DateTime.now(),
        totalTries: 0,
        correctTries: 0,
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
        ),
        width: 1000,
      ),
      actions: <Widget>[
        FlatButton(child: const Text('Cancel'), onPressed: Navigator.of(context).pop),
        FlatButton(
          child: const Text('Add'),
          onPressed: () => Navigator.of(context).pop(controller.text),
        )
      ],
    );
  }
}
