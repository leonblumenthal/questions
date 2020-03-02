import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils.dart';
import 'package:toast/toast.dart';

class DocumentWidget extends StatefulWidget {
  final Section section;
  final List<Question> questions;

  DocumentWidget(this.section, this.questions);

  @override
  _DocumentWidgetState createState() => _DocumentWidgetState();
}

class _DocumentWidgetState extends State<DocumentWidget> {
  Future<PdfDocument> documentFuture;

  @override
  void initState() {
    super.initState();
    documentFuture = PdfDocument.openFile(widget.section.documentPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.title),
      ),
      body: Container(
        child: FutureBuilder<PdfDocument>(
          future: documentFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              PdfDocument document = snapshot.data;
              return ListView.builder(
                itemBuilder: (_, i) => DocumentPage(
                  loadPage(document, i),
                  i,
                  widget.section,
                  widget.questions.where((q) => q?.marker?.pageIndex == i).toList(),
                ),
                itemCount: document.pageCount,
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

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
      [for (var q in widget.questions) QuestionPreview(q)];

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

      setState(() {
        widget.questions.add(question);
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
