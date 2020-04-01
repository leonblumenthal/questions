import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/constants.dart';
import 'package:questions/models.dart';

/// Get current date as [DateTime].
DateTime getDate() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Choose and copy file to local directory and return the new file.
Future<File> importFile() async {
  var file = await FilePicker.getFile();
  if (file == null) return null;

  // Copy selected file to local directory.
  var dir = await getApplicationDocumentsDirectory();
  var path = '${dir.path}/${file.uri.pathSegments.last}';
  await file.copy(path);

  return File(path);
}

/// Load page and render page image with scale.
Future<PdfPageImage> loadPageImage(
  PdfDocument document,
  int pageIndex, {
  double scale = 1.5,
}) async {
  var page = await document.getPage(pageIndex + 1);
  var w = page.width;
  var h = page.height;
  var pageImage = await page.render(
    fullWidth: w * scale,
    width: (w * scale).toInt(),
    fullHeight: h * scale,
    height: (h * scale).toInt(),
  );
  return pageImage;
}

/// Compare questions by streak, section and last answered
int compareQuestionsToAnswer(QuestionToAnswer a, QuestionToAnswer b) {
  var cmp = a.question.streak.compareTo(b.question.streak);
  if (cmp == 0) {
    cmp = a.section.title.compareTo(b.section.title);
    if (cmp == 0) {
      if (a.question.lastAnswered == null) {
        cmp = -1;
      } else if (b.question.lastAnswered == null) {
        cmp = 1;
      } else {
        cmp = a.question.lastAnswered.compareTo(b.question.lastAnswered);
      }
    }
  }
  return cmp;
}

Color _getStreakColor(int streak) {
  if (streak < Constants.streakColors.length) {
    return Constants.streakColors[streak];
  }
  return Constants.streakColors.last;
}

Widget buildStreakWidget(int streak) => Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      child: Text(
        streak.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStreakColor(streak),
      ),
    );
