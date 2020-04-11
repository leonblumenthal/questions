import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/document/document_screen.dart';

class LocateDocumentScreen extends DocumentScreen {
  LocateDocumentScreen(
    String title,
    PdfDocument document,
    Color color,
  ) : super(title, document, color);

  @override
  Widget buildPage(BuildContext context, int pageIndex, double pageHeight) =>
      GestureDetector(
        child: super.buildPage(context, pageIndex, pageHeight),
        onDoubleTap: () => Navigator.of(context).pop(pageIndex),
      );
}
