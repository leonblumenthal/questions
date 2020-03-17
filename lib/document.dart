import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:toast/toast.dart';

import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';

class DocumentViewer extends StatefulWidget {
  final Section section;
  final List<PdfPageImage> pageImages;
  final double initialPageIndex;
  final Map<int, List<Question>> questionsMap = {};

  DocumentViewer(
    this.section,
    this.pageImages, {
    List<Question> questions,
    this.initialPageIndex = 0,
  }) {
    // Initialize questions per page map.
    for (var i = 0; i < pageImages.length; i++) {
      questionsMap[i] = [];
    }
    // Fill map with questions.
    if (questions != null) {
      for (var q in questions) {
        if (q.marker != null) questionsMap[q.marker.pageIndex].add(q);
      }
    }
  }

  @override
  _DocumentViewerState createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  final questionPreviewHeight = 48.0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          controller: ScrollController(
            initialScrollOffset: getInitialScrollOffset(context),
          ),
          slivers: [
            SliverAppBar(
              title: Text(widget.section.title),
              floating: true,
              snap: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => buildPage(
                  widget.pageImages[i],
                  widget.questionsMap[i],
                ),
                childCount: widget.pageImages.length,
              ),
            ),
          ],
        ),
      );

  /// Calculate inital scroll offset based on initial page index.
  double getInitialScrollOffset(BuildContext context) {
    var appBarHeight = 56;
    var ratio = widget.pageImages.first.width / widget.pageImages.first.height;
    var size = MediaQuery.of(context).size;

    // Count questions that belong to preceding pages.
    var c = 0;
    for (var i = 0; i < widget.initialPageIndex; i++) {
      c += widget.questionsMap[i].length;
    }

    var offset = appBarHeight +
        c * questionPreviewHeight +
        widget.initialPageIndex * size.width / ratio -
        size.height / 3;

    if (offset <= appBarHeight) return 0;
    return offset;
  }

  Widget buildPage(PdfPageImage pageImage, List<Question> questions) =>
      Column(children: [
        GestureDetector(
          child: RawImage(image: pageImage.image),
          onDoubleTap: () {
            // Set marker in the middle of the page.
            addQuestion(Marker(0.5, pageImage.pageNumber - 0.5), context);
          },
        ),
        ...questions.map(buildQuestionPreview)
      ]);

  Widget buildQuestionPreview(Question question) => Container(
      height: questionPreviewHeight,
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
      await Storage.insertQuestion(question);

      Toast.show(
        'Created $question on page ${marker.pageIndex + 1}',
        context,
        duration: 2,
      );
      setState(() => widget.questionsMap[marker.pageIndex].add(question));
    }
  }
}
