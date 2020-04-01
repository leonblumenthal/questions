import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/constants.dart';
import 'package:questions/models.dart';
import 'package:questions/question/question_screen.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/dialog_utils.dart';
import 'package:questions/utils/utils.dart';
import 'package:toast/toast.dart';

class DocumentViewer extends StatefulWidget {
  final PdfDocument document;
  final Section section;
  final List<Future<PdfPageImage>> pageImageFutures;
  final Map<int, List<Question>> questionsMap;
  final double initialScrollOffset;
  final double pageHeight;
  final bool editable;

  DocumentViewer(
      this.document,
      this.section,
      this.pageImageFutures,
      this.questionsMap,
      this.initialScrollOffset,
      this.pageHeight,
      this.editable);

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

  Widget buildQuestionPreview(Question question) => SizedBox(
        height: Constants.questionPreviewHeight,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => QuestionScreen(question, widget.section),
            )),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: buildStreakWidget(question.streak),
                ),
                Flexible(
                  child: Text(question.text, overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          ),
        ),
      );

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
