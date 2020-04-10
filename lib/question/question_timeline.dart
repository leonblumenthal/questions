import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/utils/utils.dart';
import 'package:questions/widgets/streak_widget.dart';

class QuestionTimeline extends StatelessWidget {
  final Question question;
  final List<Answer> answers;

  QuestionTimeline(this.question, this.answers);

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var nowDate = DateTime(now.year, now.month, now.day);

    var streak = 0;
    List<Widget> items = [];

    for (var answer in answers) {
      streak++;
      if (!answer.correct) streak = 0;

      items.add(buildItemWidget(answer, streak, nowDate));

      if (answer != answers.last) items.add(Divider(height: 0));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: items.reversed.toList()),
      ),
    );
  }

  Widget buildItemWidget(Answer answer, int streak, DateTime nowDate) {
    var color = getStreakColor(streak);

    // Only show incorrect answer icon.
    Widget trailing = answer.correct
        ? null
        : Icon(Icons.sentiment_dissatisfied, color: color);

    return ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: color,
            width: 2,
            margin: EdgeInsets.only(
              // Display connection properly for first/last item.
              top: answer == answers.last ? 32 : 0,
              bottom: answer == answers.first ? 32 : 0,
            ),
          ),
          StreakWidget(streak),
        ],
      ),
      title: Text(getDurationString(answer.dateTime, nowDate)),
      trailing: trailing,
    );
  }

  String getDurationString(DateTime dateTime, DateTime nowDate) {
    var dateTimeDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    var days = nowDate.difference(dateTimeDate).inDays;
    var hourString = dateTime.toIso8601String().substring(11, 16);

    if (days == 0) return 'Today $hourString';
    if (days == 1) return 'Yesterday $hourString';
    return '$days days ago $hourString';
  }
}
