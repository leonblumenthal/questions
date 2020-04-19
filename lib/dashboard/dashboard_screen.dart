import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questions/course/course_screen.dart';
import 'package:questions/dashboard/course_item.dart';
import 'package:questions/dashboard/dashboard_provider.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:reorderables/reorderables.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => DashboardProvider(),
        child: Scaffold(
          body: CustomScrollView(
            slivers: [buildAppBar(), buildCourseList(), buildAddButton()],
          ),
          backgroundColor: Colors.white,
        ),
      );

  Widget buildAppBar() => SliverAppBar(
        title: const Text('Courses', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        floating: true,
        snap: true,
      );

  Widget buildCourseList() => Consumer<DashboardProvider>(
      builder: (_, provider, __) => SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            sliver: ReorderableSliverList(
              delegate: ReorderableSliverChildListDelegate([
                for (var c in provider.coursesWithStats)
                  CourseItem(c.course, c.stats)
              ]),
              onReorder: (from, to) async {
                var course = provider.coursesWithStats[from].course;
                await Storage.reorder(course, to);
                provider.reload();
              },
              buildDraggableFeedback: (_, constraints, child) =>
                  Container(child: child, constraints: constraints),
            ),
          ));

  Widget buildAddButton() => SliverPadding(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        sliver: SliverToBoxAdapter(
          child: Consumer<DashboardProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              iconSize: 32,
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CourseScreen(
                    Course(order: provider.coursesWithStats.length),
                  ),
                ));
                provider.reload();
              },
            ),
          ),
        ),
      );
}
