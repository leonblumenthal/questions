import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:questions/answer/answer_screen.dart';
import 'package:questions/course/course_screen.dart';
import 'package:questions/dashboard/dashboard_provider.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class CourseItem extends StatelessWidget {
  final Course course;
  final CourseStats stats;

  CourseItem(this.course, this.stats);

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(children: <Widget>[_buildText(), _buildAnswerButton()]),
          ),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CourseScreen(course),
            ));
            Provider.of<DashboardProvider>(context).reload();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: course.color.withOpacity(0.1),
          highlightColor: course.color.withOpacity(0.1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.white,
        elevation: 2,
      );

  Widget _buildText() => Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2, top: 2),
              child: _buildStatsRow(),
            )
          ],
        ),
      );

  Widget _buildAnswerButton() => FutureBuilder(
        future: Storage.getQuestionsToAnswer(course),
        builder: (context, snapshot) {
          List<QuestionToAnswer> qs = [];
          if (snapshot.hasData) qs.addAll(snapshot.data);

          if (qs.isNotEmpty) {
            return RaisedButton(
              child: Text(
                qs.length.toString(),
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: course.color,
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.all(10),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AnswerScreen(qs),
                ));
                Provider.of<DashboardProvider>(context).reload();
              },
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.check_circle_outline, color: course.color),
          );
        },
      );

  Widget _buildStatsRow() => Row(children: [
        _buildStatItem(FontAwesomeIcons.list, stats.sectionCount),
        _buildStatItem(FontAwesomeIcons.questionCircle, stats.questionCount),
        if (stats.averageStreak != null)
          _buildStatItem(FontAwesomeIcons.fire, stats.averageStreak)
      ]);

  Widget _buildStatItem(IconData icon, String text) => Row(children: [
        FaIcon(icon, size: 10, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade400)),
        const SizedBox(width: 8),
      ]);
}
