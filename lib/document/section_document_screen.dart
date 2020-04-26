import 'package:flutter/material.dart';
import 'package:questions/constants.dart';
import 'package:questions/document/document_screen.dart';
import 'package:questions/models.dart';
import 'package:questions/question/question_screen.dart';
import 'package:questions/storage.dart';
import 'package:questions/utils/dialog_utils.dart';
import 'package:questions/widgets/streak_widget.dart';
import 'package:toast/toast.dart';

class SectionDocumentScreen extends DocumentScreen {
  final Section section;
  final Map<int, List<Question>> questionsMap = {};

  SectionDocumentScreen(
    this.section,
    PdfDocumentWrapper documentWrapper,
    List<Question> questions,
    Color color, {
    double pageOffset = 0,
  }) : super(
          section.title,
          documentWrapper,
          color,
          pageOffset: pageOffset,
        ) {
    // Initialize questions per page map.
    for (var i = 0; i < documentWrapper.pageCount; i++) questionsMap[i] = [];
    // Fill map with questions.
    if (questions != null) {
      for (var q in questions) {
        if (q.marker != null) questionsMap[q.marker.pageIndex].add(q);
      }
    }
  }

  @override
  Widget buildPage(BuildContext context, int pageIndex, double pageHeight) =>
      _DocumentPage(
        super.buildPage(context, pageIndex, pageHeight),
        pageIndex,
        questionsMap[pageIndex],
        section,
        color,
      );

  @override
  double getExtraScrollOffset(int pageIndex) {
    // Count questions that belong to preceding pages.
    var c = 0;
    for (var i = 0; i < pageOffset.toInt(); i++) {
      c += questionsMap[i].length;
    }
    return c * Constants.questionPreviewHeight;
  }
}

class _DocumentPage extends StatefulWidget {
  final Widget pageWidget;
  final int pageIndex;
  final List<Question> questions;
  final Section section;
  final Color color;

  _DocumentPage(
    this.pageWidget,
    this.pageIndex,
    this.questions,
    this.section,
    this.color,
  );

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<_DocumentPage> {
  @override
  Widget build(BuildContext context) => Column(children: [
        GestureDetector(
          child: widget.pageWidget,
          onDoubleTap: addQuestion,
        ),
        ...widget.questions.map(buildQuestionPreview),
      ]);

  Widget buildQuestionPreview(Question q) => SizedBox(
      height: Constants.questionPreviewHeight,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () async {
            var deleted = await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => QuestionScreen(q, widget.section, widget.color),
            ));
            // deleted can be null.
            if (deleted == false) widget.questions.remove(q);
            setState(() {});
          },
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: StreakWidget(q.streak),
            ),
            Flexible(child: Text(q.text, overflow: TextOverflow.ellipsis))
          ]),
        ),
      ));

  Future<void> addQuestion() async {
    // Get question text with a dialog.
    var questionText = await showDialog(
      context: context,
      builder: stringDialogBuilder(
        'Add Question on Page ${widget.pageIndex + 1}',
        positive: 'Add',
      ),
    );
    // Save question and rebuild.
    if (questionText != null && questionText.isNotEmpty) {
      var question = Question(
        text: questionText,
        marker: Marker(0.5, widget.pageIndex + 0.5),
        sectionId: widget.section.id,
      );
      await Storage.insert(question);

      Toast.show(
        'Created $question on page ${widget.pageIndex + 1}',
        context,
        duration: 2,
      );
      setState(() => widget.questions.add(question));
    }
  }
}
