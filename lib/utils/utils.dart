import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/constants.dart';
import 'package:questions/document/range_document_screen.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

/// Get current date as [DateTime].
DateTime getDate([DateTime dateTime]) {
  var dt = dateTime ?? DateTime.now();
  return DateTime(dt.year, dt.month, dt.day);
}

/// Load page and render page image with scale.
Future<PdfPageImage> loadPageImage(
  PdfDocumentWrapper documentWrapper,
  int pageIndex, {
  double scale = 2.5,
}) async {
  var i = documentWrapper.startOffset + pageIndex + 1;
  var page = await documentWrapper.pdfDocument.getPage(i);
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

/// Import document for section with page range.
Future<void> importSectionDocument(
  BuildContext context,
  Section section,
) async {
  // Select pdf file.
  var file = await FilePicker.getFile();
  if (file == null) return;

  // Select page range.
  var pdfDocument = await PdfDocument.openFile(file.path);
  List<int> range = await Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => RangeDocumentScreen(
      PdfDocumentWrapper(pdfDocument),
      Colors.black,
    ),
  ));
  if (range == null) return;

  // Copy selected file to local directory.
  var dir = await getApplicationDocumentsDirectory();
  var path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}';
  await file.copy(path);

  // Delete old document if exists.
  if (section.document != null) {
    await File(section.document.path).delete().catchError((_) {});
  }

  await Storage.insert(section..document = Document(path, range[0], range[1]));
}

/// Compare questions by streak, section and last answered
int compareQuestionsToAnswer(QuestionToAnswer a, QuestionToAnswer b) {
  var cmp = a.question.streak.compareTo(b.question.streak);
  if (cmp == 0) {
    cmp = a.section.order.compareTo(b.section.order);
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

Color getStreakColor(int streak) {
  var cs = Constants.streakColors;
  return streak < cs.length ? cs[streak] : cs.last;
}
