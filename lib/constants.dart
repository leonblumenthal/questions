import 'package:flutter/material.dart';

class Constants {
  static const appBarHeight = 56.0;
  static const questionPreviewHeight = 52.0;
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
}

/// Actions for popup menu items.
enum MenuAction { delete, import, reset }