import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';
import 'package:toast/toast.dart';

class ReferenceWidget extends StatefulWidget {
  final Reference reference;

  ReferenceWidget(this.reference);

  @override
  _ReferenceWidgetState createState() => _ReferenceWidgetState();
}

class _ReferenceWidgetState extends State<ReferenceWidget> {
  Future<PdfDocument> documentFuture;
  List<MarkerAndQuestion> markersAndQuestions;

  @override
  void initState() {
    super.initState();
    documentFuture = load();
  }

  // TODO: Improve.
  Future<PdfDocument> load() async {
    markersAndQuestions = await Storage.getMarkerAndQuestions(widget.reference);
    return await PdfDocument.openFile(widget.reference.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reference.title),
      ),
      body: Container(
        child: FutureBuilder<PdfDocument>(
          future: documentFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              PdfDocument document = snapshot.data;
              return ListView.builder(
                itemBuilder: (_, i) => buildReferencePage(document, i),
                itemCount: document.pageCount,
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget buildReferencePage(PdfDocument document, int pageIndex) {
    List list = markersAndQuestions
        .where((x) => x.marker.pageIndex == pageIndex)
        .toList();

    return ReferencePage(
      loadPage(document, pageIndex),
      pageIndex,
      widget.reference,
      list,
    );
  }

  Future<PdfPageImage> loadPage(PdfDocument document, int pageIndex) async {
    PdfPage page = await document.getPage(pageIndex + 1);
    return await page.render();
  }
}

class ReferencePage extends StatefulWidget {
  final Reference reference;
  final Future<PdfPageImage> pdfImageFuture;
  final int pageId;
  final List<MarkerAndQuestion> markersAndQuestions;

  ReferencePage(
    this.pdfImageFuture,
    this.pageId,
    this.reference,
    this.markersAndQuestions,
  );

  @override
  _ReferencePageState createState() => _ReferencePageState();
}

class _ReferencePageState extends State<ReferencePage> {
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
        ...buildQuestionPreviews()
      ],
    );
  }

  Widget buildPage(PdfPageImage pageImage) => GestureDetector(
        child: RawImage(image: pageImage.image),
        onLongPressEnd: (details) => addQuestion(
          getMarker(details, context),
          context,
        ),
      );

  List<Widget> buildQuestionPreviews() =>
      [for (var x in widget.markersAndQuestions) QuestionPreview(x.question)];

  /// Get a marker with page index and relative position on the page.
  Marker getMarker(LongPressEndDetails details, BuildContext context) {
    Offset position = details.localPosition;
    RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;
    return Marker(
      pageIndex: widget.pageId,
      px: position.dx / size.width,
      py: position.dy / size.height,
      referenceId: widget.reference.id,
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

    // Save marker and question and rebuild widget.
    if (questionText != null && questionText.isNotEmpty) {
      await Storage.insertMarker(marker);
      Question question = Question(
        text: questionText,
        markerId: marker.id,
      );
      await Storage.insertQuestion(question);

      Toast.show(
        'Created $question on page ${marker.pageIndex + 1}',
        context,
        duration: 2,
      );

      setState(() {
        widget.markersAndQuestions.add(MarkerAndQuestion(marker, question));
      });
    }
  }
}

class QuestionPreview extends StatelessWidget {
  final Question question;

  QuestionPreview(this.question);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(question.text),
    );
  }
}
