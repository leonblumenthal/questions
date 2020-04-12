import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questions/course/course_screen.dart';
import 'package:questions/dashboard/course_item.dart';
import 'package:questions/dashboard/dashboard_provider.dart';
import 'package:questions/models.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => DashboardProvider(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              buildAppBar(),
              buildCourseList(),
              SliverPadding(padding: const EdgeInsets.all(42))
            ],
          ),
          floatingActionButton: buildAddButton(context),
        ),
      );

  Widget buildAppBar() => SliverAppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        floating: true,
        snap: true,
        forceElevated: true,
      );

  Widget buildCourseList() => Consumer<DashboardProvider>(
      builder: (_, provider, __) => SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              children: provider.coursesWithStats
                  .map((c) => CourseItem(c.course, c.stats))
                  .toList(),
              childAspectRatio: 1.618, // golden ratio
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
          ));

  Widget buildAddButton(BuildContext context) => FloatingActionButton(
        child: const Icon(Icons.add, size: 32, color: Colors.black),
        backgroundColor: Colors.white,
        shape: CircleBorder(),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CourseScreen(Course()),
          ));
          Provider.of<DashboardProvider>(context).reload();
        },
      );
}
