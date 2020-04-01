import 'dart:io';

import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/section/section_screen.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/dialog_utils.dart';
import 'package:questions/utils/utils.dart';
import 'package:toast/toast.dart';

class CourseScreen extends StatefulWidget {
  final Course course;

  CourseScreen(this.course);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final titleController = TextEditingController();
  Future<List<Section>> sectionsFuture;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.course.title;
    sectionsFuture = Storage.getSections(widget.course);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        floatingActionButton: hideBeforeSave(buildFabs()),
        body: buildSectionList(),
      );

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
          await Storage.insert(widget.course..title = title.trim());
          setState(() {});
        },
      ),
      actions: hideBeforeSave([
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: deleteCourse,
        )
      ]));

  Widget buildFabs() => Wrap(
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 1,
            child: const Icon(Icons.add),
            onPressed: () => goToSection(Section(courseId: widget.course.id)),
            mini: true,
          ),
          FloatingActionButton(
            child: const Icon(Icons.library_add),
            onPressed: addSectionWithDocument,
          ),
        ],
      );

  Future addSectionWithDocument() async {
    var file = await importFile();
    if (file != null) {
      var section = Section(
        title: file.uri.pathSegments.last.split('.').first,
        courseId: widget.course.id,
        documentPath: file.path,
      );
      await Storage.insert(section);

      goToSection(section);
    }
  }

  Widget buildSectionList() => FutureBuilder(
      future: sectionsFuture,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          List<Section> sections = snapshot.data;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 84),
            itemBuilder: (_, i) => buildSectionItem(sections[i]),
            itemCount: sections.length,
          );
        }
        return const Center(child: CircularProgressIndicator());
      });

  Widget buildSectionItem(Section section) => Card(
        child: ListTile(
          title: Text(section.title),
          trailing: section.documentPath == null
              ? const Icon(Icons.location_off, size: 16)
              : null,
          onTap: () => goToSection(section),
        ),
      );

  void reloadSections() {
    sectionsFuture = Storage.getSections(widget.course);
    setState(() {});
  }

  Future<void> deleteCourse() async {
    // Course has not been saved.
    if (widget.course.id == null) Navigator.of(context).pop();

    bool result = await showDialog(
      context: context,
      builder: boolDialogBuilder(
        'Delete course',
        'Are you sure that you want to delete ${widget.course} ?',
      ),
    );
    if (result) {
      // Delete all document for the course.
      for (var section in await sectionsFuture) {
        var path = section.documentPath;
        if (path != null) await File(path).delete().catchError((_){});
      }
      // Delete course with sections and questions.
      await Storage.delete(widget.course);
      Toast.show('Deleted ${widget.course}', context, duration: 2);
      Navigator.of(context).pop();
    }
  }

  Future goToSection(Section section) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SectionScreen(section)),
    );
    reloadSections();
  }

  dynamic hideBeforeSave(w) => widget.course.id == null ? null : w;
}
