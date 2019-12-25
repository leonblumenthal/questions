import 'package:flutter/material.dart';
import 'package:questions/home.dart';
import 'package:questions/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  runApp(
    MaterialApp(
      title: 'Questions',
      home: Home(),
    ),
  );
}


