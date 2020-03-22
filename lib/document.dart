import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:toast/toast.dart';

import 'package:questions/constants.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

class DocumentScreen extends StatelessWidget {
  final Section section;
  final PdfDocument document;
  final double initialPageOffset;
  final Map<int, List<Question>> questionsMap = {};
  final List<Future<PdfPageImage>> pageFutures = [];
  final bool editable;

  DocumentScreen(
    this.section,
    this.document, {
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
    for (var i = 0; i < document.pageCount; i++) {
      pageFutures.add(loadPageImage(document, i));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder(
          future: pageFutures[initialPageOffset.toInt()],
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
                section,
                pageFutures,
                questionsMap,
                offset,
                pageHeight,
                editable
              );
            }
            return Container();
          },
        ),
      );
}

class DocumentViewer extends StatefulWidget {
  final Section section;
  final List<Future<PdfPageImage>> pageImageFutures;
  final Map<int, List<Question>> questionsMap;
  final double initialScrollOffset;
  final double pageHeight;
  final bool editable;

  DocumentViewer(this.section, this.pageImageFutures, this.questionsMap,
      this.initialScrollOffset, this.pageHeight, this.editable);

  @override
  _DocumentViewerState createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          controller: ScrollController(
            initialScrollOffset: widget.initialScrollOffset,
          ),
          slivers: [
            SliverAppBar(
              title: Text(widget.section.title),
              floating: true,
              snap: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => buildPage(i),
                childCount: widget.pageImageFutures.length,
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    super.dispose();
    for (var it in widget.pageImageFutures) {
      it.then((p) => p.dispose());
    }
  }

  Widget buildPage(int pageIndex) => Column(children: [
        Container(
            height: widget.pageHeight,
            child: FutureBuilder(
                future: widget.pageImageFutures[pageIndex],
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return GestureDetector(
                      child: RawImage(image: snapshot.data.image),
                      onDoubleTap: widget.editable
                          ? () =>
                              addQuestion(Marker(0.5, pageIndex + 0.5), context)
                          : null,
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                })),
        ...widget.questionsMap[pageIndex].map(buildQuestionPreview)
      ]);

  Widget buildQuestionPreview(Question question) => Container(
      height: Constants.questionPreviewHeight,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(label: Text(question.streak.toString())),
          ),
          Flexible(child: Text(question.text, overflow: TextOverflow.ellipsis))
        ],
      ));

  Future<void> addQuestion(Marker marker, BuildContext context) async {
    // Get question text with a dialog.
    var questionText = await showDialog(
      context: context,
      builder: stringDialogBuilder(
        'Add Question on Page ${marker.pageIndex + 1}',
        positive: 'Add',
      ),
    );
    // Save question and rebuild.
    if (questionText != null && questionText.isNotEmpty) {
      var question = Question(
        text: questionText,
        marker: marker,
        sectionId: widget.section.id,
      );
      await Storage.insert(question);

      Toast.show(
        'Created $question on page ${marker.pageIndex + 1}',
        context,
        duration: 2,
      );
      setState(() => widget.questionsMap[marker.pageIndex].add(question));
    }
  }
}
