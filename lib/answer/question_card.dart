import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/utils/utils.dart';

class QuestionCard extends StatelessWidget {
  final QuestionToAnswer qta;

  QuestionCard(this.qta);

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Text(qta.course.title, style: const TextStyle(fontSize: 12)),
          Text(
            qta.section.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              qta.question.text,
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: buildStreakWidget(qta.question.streak),
          )
        ]),
      ));
}
