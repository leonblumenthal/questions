import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/section.dart';
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
  Future<List<Section>> sectionsFuture;

  @override
  void initState() {
    super.initState();
    controller.text = widget.course.title;
    sectionsFuture = Storage.getSections(widget.course);
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
          <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteCourse,
            ),
          ],
        ),
      ),
      floatingActionButton: hideBeforeSave(
        FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => goToSection(Section(courseId: widget.course.id)),
        ),
      ),
      body: buildSectionList(),
    );
  }

  Widget buildSectionList() => FutureBuilder(
        future: sectionsFuture,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            List<Section> sections = snapshot.data;
            return ListView.builder(
              itemBuilder: (_, i) => ListTile(
                title: Text(sections[i].title),
                onTap: () => goToSection(sections[i]),
              ),
              itemCount: sections.length,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );

  void reloadSections() {
    sectionsFuture = Storage.getSections(widget.course);
    setState(() {});
  }

  Future saveTitle(String title) async {
    await Storage.insertCourse(widget.course..title = title.trim());
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
      if (result) {
        await Storage.deleteCourse(widget.course);
        Toast.show('Deleted ${widget.course}', context, duration: 2);
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
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

  Future goToSection(Section section) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SectionWidget(section)),
    );
    reloadSections();
  }

  hideBeforeSave(w) => widget.course.id == null ? null : w;
}
