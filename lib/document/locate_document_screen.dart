import 'package:flutter/material.dart';
import 'package:questions/document/document_screen.dart';
import 'package:questions/models.dart';

class LocateDocumentScreen extends DocumentScreen {
  LocateDocumentScreen(PdfDocumentWrapper documentWrapper, Color color)
      : super('Locate question page', documentWrapper, color);

  @override
  Widget buildPage(BuildContext context, int pageIndex, double pageHeight) =>
      GestureDetector(
        child: super.buildPage(context, pageIndex, pageHeight),
        onDoubleTap: () => Navigator.of(context).pop(pageIndex),
      );
}
