import 'package:flutter/material.dart';
import 'package:questions/models.dart';
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
          decoration: InputDecoration(border: InputBorder.none),
          style: TextStyle(
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
            icon: Icon(Icons.delete),
            onPressed: () => deleteCourse(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await addQuestion(context);
          questionsFuture = Storage.getQuestions(widget.course);
          setState((() {}));
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
                onTap: () {},
              ),
              itemCount: questions.length,
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      );

  Future saveTitle(String title, BuildContext context) async {
    await Storage.insertCourse(widget.course..title = title);
    Toast.show('Saved ${widget.course}', context, duration: 2);
  }

  Future deleteCourse(BuildContext context) async {
    if (widget.course.id != null) {
      await Storage.deleteCourse(widget.course);
      Toast.show('Deleted ${widget.course}', context, duration: 2);
    }
    Navigator.of(context).pop();
  }

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
      title: Text('Add Question'),
      content: Container(
        child: TextField(
          controller: controller,
          maxLines: 1,
          style: TextStyle(fontSize: 16),
          autofocus: true,
        ),
        width: 1000,
      ),
      actions: <Widget>[
        FlatButton(child: Text('Cancel'), onPressed: Navigator.of(context).pop),
        FlatButton(
          child: Text('Add'),
          onPressed: () => Navigator.of(context).pop(controller.text),
        )
      ],
    );
  }
}
