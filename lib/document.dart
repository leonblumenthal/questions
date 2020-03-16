import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';
import 'package:toast/toast.dart';

class DocumentViewer extends StatefulWidget {
  final Section section;
  final List<PdfPageImage> pageImages;
  final double initialPageIndex;
  final Map<int, List<Question>> questionsMap = Map();

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
    if (questions != null)
      questions
          .where((q) => q.marker != null)
          .forEach((q) => questionsMap[q.marker.pageIndex].add(q));
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
          slivers: <Widget>[
            SliverAppBar(
              title: Text(widget.section.title),
              floating: true,
              snap: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => buildPage(
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
    int appBarHeight = 56;
    double ratio =
        widget.pageImages.first.width / widget.pageImages.first.height;
    Size size = MediaQuery.of(context).size;
    int questionAmount = 0;
    for (var i = 0; i < widget.initialPageIndex; i++) {
      questionAmount += widget.questionsMap[i].length;
    }
    double offset = appBarHeight +
        questionAmount * questionPreviewHeight +
        widget.initialPageIndex * size.width / ratio -
        size.height / 3;

    return offset <= appBarHeight ? 0 : offset;
  }

  Widget buildPage(PdfPageImage pageImage, List<Question> questions) => Column(
        children: <Widget>[
          GestureDetector(
            child: RawImage(image: pageImage.image),
            onDoubleTap: () => addQuestion(
              Marker(pageIndex: pageImage.pageNumber - 1),
              context,
            ),
          ),
          ...questions.map(buildQuestionPreview)
        ],
      );

  Widget buildQuestionPreview(Question question) => Container(
        height: questionPreviewHeight,
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(label: Text(question.streak.toString())),
            ),
            Flexible(
              child: Text(
                question.text,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      );

  Future addQuestion(Marker marker, BuildContext context) async {
    // Get question text with a dialog.
    String questionText = await showDialog(
      context: context,
      builder: Utils.stringDialogBuilder(
        'Add Question on Page ${marker.pageIndex + 1}',
        positive: 'Add',
      ),
    );

    // Save question and rebuild page.
    if (questionText != null && questionText.isNotEmpty) {
      Question question = Question(
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
