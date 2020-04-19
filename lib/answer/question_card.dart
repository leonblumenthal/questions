import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/widgets/streak_widget.dart';

class QuestionCard extends StatelessWidget {
  final QuestionToAnswer qta;

  QuestionCard(this.qta);

  @override
  Widget build(BuildContext context) => Card(
        child: Container(
          child: Column(children: [
            buildTitle(),
            const Divider(),
            buildContent(),
            Align(
              alignment: Alignment.centerRight,
              child: StreakWidget(qta.question.streak),
            )
          ]),
          padding: const EdgeInsets.all(8),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 2,
      );

  Widget buildTitle() => Padding(
        child: Text(
          '${qta.course.title} - ${qta.section.title}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        padding: const EdgeInsets.all(8),
      );

  Widget buildContent() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Text(
          qta.question.text,
          style: const TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      );
}
