import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:questions/dashboard/dashboard_screen.dart';
import 'package:questions/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  await Storage.init();
  runApp(MaterialApp(
    title: 'Questions',
    home: DashboardScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
