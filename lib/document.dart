import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/models.dart';
import 'package:questions/question.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';
import 'package:toast/toast.dart';

class DocumentWidget extends StatelessWidget {
  final Section section;
  final Map<int, List<Question>> pageQuestions = Map();

  DocumentWidget(this.section);

  Future<PdfDocument> load() async {
    // Load questions and initialize page questions map;
    List<Question> qs = await Storage.getQuestions(section);
    for (var question in qs) {
      if (question.marker != null) {
        int i = question.marker.pageIndex;
        pageQuestions.putIfAbsent(i, () => []);
        pageQuestions[i].add(question);
      }
    }
    // Load pdf document.
    return await PdfDocument.openFile(section.documentPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
      ),
      body: buildPageList(),
    );
  }

  Widget buildPageList() => Container(
        child: FutureBuilder<PdfDocument>(
          future: load(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              PdfDocument document = snapshot.data;
              // Initialize all empty question lists for the missing pages.
              for (var i = 0; i < document.pageCount; i++) {
                pageQuestions.putIfAbsent(i, () => []);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(4),
                itemBuilder: (_, i) => DocumentPage(
                  loadPage(document, i),
                  i,
                  section,
                  pageQuestions[i],
                ),
                itemCount: document.pageCount,
              );
            }
            return CircularProgressIndicator();
          },
        ),
      );

  Future<PdfPageImage> loadPage(PdfDocument document, int pageIndex) async {
    PdfPage page = await document.getPage(pageIndex + 1);
    return await page.render();
  }
}

class DocumentPage extends StatefulWidget {
  final Future<PdfPageImage> pdfImageFuture;
  final int pageId;
  final Section section;
  final List<Question> questions;

  DocumentPage(this.pdfImageFuture, this.pageId, this.section, this.questions);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<PdfPageImage>(
          future: widget.pdfImageFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) return buildPage(snapshot.data);
            return CircularProgressIndicator();
          },
        ),
        ...widget.questions.map(buildQuestionPreview)
      ],
    );
  }

  Widget buildPage(PdfPageImage pageImage) => Card(
        child: GestureDetector(
          child: ClipRRect(
            child: RawImage(image: pageImage.image),
            borderRadius: BorderRadius.circular(4),
          ),
          onLongPressEnd: (details) => addQuestion(
            getMarker(details, context),
            context,
          ),
        ),
      );

  Widget buildQuestionPreview(Question question) => Card(
        child: InkWell(
          onTap: () async {
            var result = await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => QuestionWidget(question),
            ));
            if (result != null && !result) {
              setState(() => widget.questions.remove(question));
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Chip(
                  label: Text(question.streak.toString()),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                  child: Text(question.text),
                ),
              ),
            ],
          ),
        ),
      );

  /// Get a marker with page index and relative position on the page.
  Marker getMarker(LongPressEndDetails details, BuildContext context) {
    Offset position = details.localPosition;
    RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;
    return Marker(
      pageIndex: widget.pageId,
      px: position.dx / size.width,
      py: position.dy / size.height,
    );
  }

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

      setState(() => widget.questions.add(question));
    }
  }
}
