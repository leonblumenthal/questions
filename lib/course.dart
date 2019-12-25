import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:toast/toast.dart';

class CourseWidget extends StatelessWidget {
  final Course course;

  final TextEditingController controller = TextEditingController();

  CourseWidget(this.course) {
    controller.text = course.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          decoration: InputDecoration(border: InputBorder.none),
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.white,
          autofocus: controller.text.isEmpty,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (String title) => saveTitle(title, context),
        ),
      ),
    );
  }

  void saveTitle(String title, BuildContext context) async {
    course.title = title;
    await Storage.insertCourse(course);
    Toast.show('Saved $course', context, duration: 2);
  }
}
