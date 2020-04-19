import 'package:flutter/material.dart';

class Constants {
  static const appBarHeight = 56.0;
  static const questionPreviewHeight = 52.0;
  static const listViewPadding = const EdgeInsets.fromLTRB(4, 4, 4, 84);
  static const streakColors = [
    Colors.pinkAccent,
    Colors.deepOrangeAccent,
    Colors.orangeAccent,
    Colors.amberAccent,
    Colors.lightGreenAccent,
    Colors.tealAccent,
    Colors.lightBlueAccent,
    Colors.indigoAccent,
    Colors.black
  ];
  static final courseColors = [
    Colors.redAccent.shade100,
    Colors.pinkAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.deepPurpleAccent.shade100,
    Colors.indigoAccent.shade100,
    Colors.blueAccent.shade100,
    Colors.lightBlueAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.amberAccent.shade100,
    Colors.orangeAccent.shade100,
    Colors.deepOrangeAccent.shade100,
    Colors.brown.shade300,
    Colors.blueGrey.shade200,
  ];
}

/// Actions for popup menu items.
enum MenuAction { delete, import, reset, color }
