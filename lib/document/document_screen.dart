import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/constants.dart';
import 'package:questions/document/document_viewer.dart';
import 'package:questions/models.dart';
import 'package:questions/utils/utils.dart';

class DocumentScreen extends StatelessWidget {
  final Section section;
  final Color color;
  final PdfDocument document;
  final double initialPageOffset;
  final Map<int, List<Question>> questionsMap = {};
  final Map<int, Future<PdfPageImage>> pageImageFutures = {};
  final bool editable;

  DocumentScreen(
    this.section,
    this.document, 
    this.color,{
    List<Question> questions,
    this.initialPageOffset = 0,
    this.editable = true,
  }) {
    // Initialize questions per page map.
    for (var i = 0; i < document.pageCount; i++) {
      questionsMap[i] = [];
    }
    // Fill map with questions.
    if (questions != null) {
      for (var q in questions) {
        if (q.marker != null) questionsMap[q.marker.pageIndex].add(q);
      }
    }
    var i = initialPageOffset.toInt();
    pageImageFutures[i] = loadPageImage(document, i);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder(
          future: pageImageFutures[initialPageOffset.toInt()],
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              var pageImage = snapshot.data;

              var ratio = pageImage.width / pageImage.height;
              var size = MediaQuery.of(context).size;
              var pageHeight = size.width / ratio;

              // Count questions that belong to preceding pages.
              var c = 0;
              for (var i = 0; i < initialPageOffset.toInt(); i++) {
                c += questionsMap[i].length;
              }

              var offset = Constants.appBarHeight +
                  c * Constants.questionPreviewHeight +
                  initialPageOffset * pageHeight -
                  size.height / 3;

              if (offset <= Constants.appBarHeight) offset = 0;

              return DocumentViewer(
                document,
                section,
                color,
                pageImageFutures,
                questionsMap,
                offset,
                pageHeight,
                editable,
              );
            }
            return Container();
          },
        ),
      );
}
