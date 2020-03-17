import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';

/// Get current date as [DateTime].
DateTime getDate() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

AlertDialog Function(BuildContext) boolDialogBuilder(
  String title,
  String content, {
  String negative = 'No',
  String positive = 'Yes',
}) =>
    (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            FlatButton(
              child: Text(negative),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(positive),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        );

AlertDialog Function(BuildContext) stringDialogBuilder(
  String title, {
  String negative = 'Cancel',
  String positive = 'Ok',
}) =>
    (context) {
      var controller = TextEditingController();
      return AlertDialog(
        title: Text(title),
        content: Container(
          child: TextField(
            controller: controller,
            maxLines: 1,
            style: const TextStyle(fontSize: 16),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          width: 1000,
        ),
        actions: [
          FlatButton(
            child: Text(negative),
            onPressed: Navigator.of(context).pop,
          ),
          FlatButton(
            child: Text(positive),
            onPressed: () => Navigator.of(context).pop(controller.text),
          )
        ],
      );
    };

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
