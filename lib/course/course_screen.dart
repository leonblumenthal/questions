import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questions/constants.dart';
import 'package:questions/course/course_provider.dart';
import 'package:questions/course/section_item.dart';
import 'package:questions/models.dart';
import 'package:questions/section/section_screen.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/dialog_utils.dart';
import 'package:questions/utils/utils.dart';
import 'package:questions/widgets/app_bar_text_field.dart';
import 'package:reorderables/reorderables.dart';
import 'package:toast/toast.dart';

class CourseScreen extends StatelessWidget {
  final Course course;
  final titleController = TextEditingController();

  CourseScreen(this.course) {
    titleController.text = course.title;
    if (course.id == null) {
      // Set random course color.
      var cs = Constants.courseColors;
      course.color = cs[Random().nextInt(cs.length)];
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => CourseProvider(course),
        child: Scaffold(
          body: CustomScrollView(slivers: [buildAppBar(), buildSectionList()]),
          floatingActionButton: hideBeforeSave(buildFabs()),
        ),
      );

  Widget buildAppBar() => Consumer<CourseProvider>(
        builder: (context, provider, __) => SliverAppBar(
          title: AppBarTextField(
            controller: titleController,
            onSubmitted: provider.setTitle,
          ),
          actions: hideBeforeSave([buildActionMenu(context)]),
          backgroundColor: course.color,
          floating: true,
          snap: true,
          forceElevated: true,
        ),
      );

  Widget buildActionMenu(BuildContext context) => PopupMenuButton(
        onSelected: (MenuAction action) async {
          if (action == MenuAction.delete) deleteCourse(context);
          if (action == MenuAction.color) changeColor(context);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(child: Text('Delete course'), value: MenuAction.delete),
          PopupMenuItem(child: Text('Change color'), value: MenuAction.color),
        ],
      );

  Widget buildFabs() => Consumer<CourseProvider>(
        builder: (context, provider, _) => Wrap(
          children: [
            FloatingActionButton(
              heroTag: 1,
              child: const Icon(Icons.add),
              onPressed: () => goToSection(
                context,
                Section(courseId: course.id, order: provider.sections.length),
              ),
              mini: true,
              backgroundColor: course.color,
            ),
            FloatingActionButton(
              child: const Icon(Icons.library_add),
              onPressed: () => addSectionWithDocument(
                context,
                Section(courseId: course.id, order: provider.sections.length),
              ),
              backgroundColor: course.color,
            ),
          ],
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
        ),
      );

  Widget buildSectionList() => Consumer<CourseProvider>(
        builder: (_, provider, __) => SliverPadding(
            padding: const EdgeInsets.only(top: 6, bottom: 84),
            sliver: ReorderableSliverList(
              delegate: ReorderableSliverChildBuilderDelegate(
                (_, i) => SectionItem(provider.sections[i], course.color),
                childCount: provider.sections.length,
              ),
              onReorder: (from, to) async {
                await Storage.reorder(provider.sections[from], to);
                provider.reload();
              },
              buildDraggableFeedback: (_, constraints, child) =>
                  Container(child: child, constraints: constraints),
            )),
      );

  void addSectionWithDocument(
    BuildContext context,
    Section section,
  ) async {
    var file = await importFile();
    if (file != null) {
      section
        ..title = file.uri.pathSegments.last.split('.').first
        ..documentPath = file.path;
      await Storage.insert(section);
      goToSection(context, section);
    }
  }

  void deleteCourse(BuildContext context) async {
    bool result = await showDialog(
      context: context,
      builder: boolDialogBuilder(
        'Delete course',
        'Are you sure that you want to delete $course ?',
      ),
    );
    if (result) {
      await Provider.of<CourseProvider>(context).deleteCourse();
      Toast.show('Deleted $course', context, duration: 2);
      Navigator.of(context).pop();
    }
  }

  void changeColor(BuildContext context) async {
    var color = await showDialog(
      context: context,
      builder: colorDialogBuilder(
        'Choose course color',
        Constants.courseColors,
      ),
    );
    if (color != null) Provider.of<CourseProvider>(context).setColor(color);
  }

  void goToSection(BuildContext context, Section section) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SectionScreen(section, course.color),
    ));
    Provider.of<CourseProvider>(context).reload();
  }

  dynamic hideBeforeSave(w) => course.id == null ? null : w;
}
