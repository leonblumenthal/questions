import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:questions/constants.dart';
import 'package:questions/models.dart';
import 'package:questions/section/section_screen.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/dialog_utils.dart';
import 'package:questions/utils/utils.dart';
import 'package:questions/widgets/app_bar_text_field.dart';
import 'package:toast/toast.dart';

class CourseScreen extends StatefulWidget {
  final Course course;

  CourseScreen(this.course) {
    if (course.id == null) {
      // Set random course color.
      var cs = Constants.courseColors;
      course.color = cs[Random().nextInt(cs.length)];
    }
  }

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
        body: CustomScrollView(slivers: [buildAppBar(), buildSectionList()]),
        floatingActionButton: hideBeforeSave(buildFabs()),
      );

  Widget buildAppBar() => SliverAppBar(
        title: AppBarTextField(
          controller: titleController,
          onSubmitted: (title) async {
            await Storage.insert(widget.course..title = title.trim());
            setState(() {});
          },
        ),
        actions: hideBeforeSave([buildActionMenu()]),
        backgroundColor: widget.course.color,
        floating: true,
        snap: true,
        forceElevated: true,
      );

  Widget buildActionMenu() => PopupMenuButton(
        onSelected: (MenuAction action) async {
          if (action == MenuAction.delete) deleteCourse();
          if (action == MenuAction.color) changeColor();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(child: Text('Delete course'), value: MenuAction.delete),
          PopupMenuItem(child: Text('Change color'), value: MenuAction.color),
        ],
      );

  Widget buildFabs() => Wrap(
        children: [
          FloatingActionButton(
            heroTag: 1,
            child: const Icon(Icons.add),
            onPressed: () => goToSection(Section(courseId: widget.course.id)),
            mini: true,
            backgroundColor: widget.course.color,
          ),
          FloatingActionButton(
            child: const Icon(Icons.library_add),
            onPressed: addSectionWithDocument,
            backgroundColor: widget.course.color,
          ),
        ],
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 16,
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
        List<Section> sections = [];
        if (snapshot.hasData) sections.addAll(snapshot.data);
        return SliverPadding(
          padding: const EdgeInsets.only(top: 6, bottom: 84),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => buildSectionItem(sections[i]),
              childCount: sections.length,
            ),
          ),
        );
      });

  Widget buildSectionItem(Section section) => Card(
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  section.title,
                  style: const TextStyle(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (section.documentPath == null)
                  const Icon(Icons.location_off, size: 16, color: Colors.grey)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          onTap: () => goToSection(section),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  void reloadSections() {
    sectionsFuture = Storage.getSections(widget.course);
    setState(() {});
  }

  Future<void> deleteCourse() async {
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
        if (path != null) await File(path).delete().catchError((_) {});
      }
      // Delete course with sections and questions.
      await Storage.delete(widget.course);
      Toast.show('Deleted ${widget.course}', context, duration: 2);
      Navigator.of(context).pop();
    }
  }

  Future<void> changeColor() async {
    var color = await showDialog(
      context: context,
      builder: colorDialogBuilder(
        'Choose course color',
        Constants.courseColors,
      ),
    );
    if (color != null) {
      await Storage.insert(widget.course..color = color);
      setState(() {});
    }
  }

  Future goToSection(Section section) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => SectionScreen(section, widget.course.color)),
    );
    reloadSections();
  }

  dynamic hideBeforeSave(w) => widget.course.id == null ? null : w;
}
