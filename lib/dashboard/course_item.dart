import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:questions/course/course_screen.dart';
import 'package:questions/dashboard/dashboard_provider.dart';
import 'package:questions/models.dart';

class CourseItem extends StatelessWidget {
  final Course course;
  final CourseStats stats;

  CourseItem(this.course, this.stats);
  @override
  Widget build(BuildContext context) => Card(
      shadowColor: course.color,
      elevation: 2,
      margin: EdgeInsets.zero,
      color: course.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        highlightColor: Colors.white.withAlpha(32),
        splashColor: Colors.white.withAlpha(32),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CourseScreen(course),
          ));
          Provider.of<DashboardProvider>(context).reload();
        },
        borderRadius: BorderRadius.circular(8),
        child: _buildContent(),
      ));

  Widget _buildContent() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            course.title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          _buildStatsRow()
        ],
      ));

  Widget _buildStatsRow() =>
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (stats.sectionCount > 0)
          _buildStatItem(FontAwesomeIcons.list, stats.sectionCount),
        if (stats.questionCount > 0)
          _buildStatItem(FontAwesomeIcons.questionCircle, stats.questionCount),
        if (stats.averageStreak != null)
          _buildStatItem(
            FontAwesomeIcons.fire,
            stats.averageStreak.toStringAsFixed(1),
          )
      ]);

  Widget _buildStatItem(IconData icon, dynamic text) => Row(children: [
        const SizedBox(width: 8),
        FaIcon(icon, size: 10, color: Colors.white),
        const SizedBox(width: 4),
        Text(text.toString(), style: const TextStyle(color: Colors.white)),
      ]);
}
