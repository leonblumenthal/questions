import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

class ImportWidget extends StatefulWidget {
  @override
  _ImportWidgetState createState() => _ImportWidgetState();
}

class _ImportWidgetState extends State<ImportWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        child: Text('Import'),
        onPressed: () async {
          await import();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future import() async {
    File file = await FilePicker.getFile();
    if (file == null) return;

    // Parse file and store parsed objects.
    parse(file.readAsStringSync()).forEach((courseImport) async {
      await Storage.insertCourse(courseImport.course);
      courseImport.sectionImports.forEach((sectionImport) async {
        await Storage.insertSection(
          sectionImport.section..courseId = courseImport.course.id,
        );
        sectionImport.questionImports.forEach(
          (questionImport) => Storage.insertQuestion(
            questionImport.question..sectionId = sectionImport.section.id,
          ),
        );
      });
    });
  }

  /// Parse markdown file into courses, sections and questions.
  List<CourseImport> parse(String raw) {
    List<CourseImport> courseImports = [];

    List<String> lines = [
      for (String line in raw.split('\n')) if (line.isNotEmpty) line.trim()
    ];

    // Skip to first course.
    lines = lines.skipWhile((line) => !line.startsWith('# ')).toList();

    while (lines.isNotEmpty) {
      CourseImport courseImport = CourseImport(
        Course(title: lines.first.substring(2)),
      );
      courseImports.add(courseImport);
      // Skip course title.
      lines = lines.skip(1).toList();
      // Take all lines before the next course and skip to first section
      List<String> courseLines = lines
          .takeWhile(isNotCourseTitle)
          .skipWhile(isNotSectionTitle)
          .toList();

      while (courseLines.isNotEmpty) {
        SectionImport sectionImport = SectionImport(
          Section(title: courseLines.first.substring(3)),
          courseImport,
        );
        courseImport.sectionImports.add(sectionImport);
        // Skip section title.
        courseLines = courseLines.skip(1).toList();
        // Take all lines before the next section and remove invalid lines.
        List<String> sectionLines = courseLines
            .takeWhile(isNotSectionTitle)
            .where(isQuestionText)
            .toList();
        for (String line in sectionLines) {
          sectionImport.questionImports.add(QuestionImport(
            Question(text: line.substring(2)),
            sectionImport,
          ));
        }
        // Remove section lines from course lines.
        courseLines = courseLines.skipWhile(isNotSectionTitle).toList();
      }
      // Remove course lines from all lines.
      lines = lines.skipWhile(isNotCourseTitle).toList();
    }
    return courseImports;
  }

  // helper methods for parsing 

  bool isNotCourseTitle(String line) => !line.startsWith('# ');
  bool isNotSectionTitle(String line) => !line.startsWith('## ');
  bool isQuestionText(String line) => line.startsWith('- ');
}
