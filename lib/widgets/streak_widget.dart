import 'package:flutter/material.dart';
import 'package:questions/utils/utils.dart';

class StreakWidget extends StatelessWidget {
  final int streak;
  final Color color;

  StreakWidget(this.streak) : color = getStreakColor(streak);

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Text(
          streak.toString(),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          color: Colors.white,
        ),
      );
}
