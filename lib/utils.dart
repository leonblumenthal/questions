import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';

class Utils {
  /// Get current date as [DateTime].
  static DateTime getDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Function boolDialogBuilder(
    String title,
    String content, {
    String negative = 'No',
    String positive = 'Yes',
  }) =>
      (BuildContext context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
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

  static Function stringDialogBuilder(
    String title, {
    String negative = 'Cancel',
    String positive = 'Ok',
  }) =>
      (BuildContext context) {
        TextEditingController controller = TextEditingController();
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
          actions: <Widget>[
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
  static Future<File> importFile() async {
    File file = await FilePicker.getFile();
    if (file == null) return null;

    // Copy selected file to local directory.
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/${file.uri.pathSegments.last}';
    await file.copy(path);

    return File(path);
  }

  /// Load pdf and render all pages with given [scalar].
  static Future<List<PdfPageImage>> loadPageImages(
    String path, {
    double scalar = 1,
  }) async {
    var document = await PdfDocument.openFile(path);
    List<PdfPageImage> pageImages = [];

    for (var i = 0; i < document.pageCount; i++) {
      var page = await document.getPage(i + 1);
      var w = page.width;
      var h = page.height;
      var pageImage = await page.render(
        fullWidth: w * scalar,
        width: (w * scalar).toInt(),
        fullHeight: h * scalar,
        height: (h * scalar).toInt(),
      );
      pageImages.add(pageImage);
    }

    return pageImages;
  }
}
