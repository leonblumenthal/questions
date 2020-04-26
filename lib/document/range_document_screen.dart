import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questions/document/document_screen.dart';
import 'package:questions/models.dart';

class RangeDocumentScreen extends DocumentScreen {
  RangeDocumentScreen(PdfDocumentWrapper documentWrapper, Color color)
      : super('Select page range', documentWrapper, color);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<RangeProvider>(
        create: (_) => RangeProvider(),
        child: Scaffold(
          body: super.build(context),
          floatingActionButton: Consumer<RangeProvider>(
            builder: (context, provider, _) => FloatingActionButton(
              child: Icon(Icons.check),
              backgroundColor: Colors.black,
              onPressed: () {
                var range = [provider.startIndex ?? 0, provider.endIndex ?? -1];
                Navigator.of(context).pop(range);
              },
            ),
          ),
        ),
      );

  @override
  Widget buildPage(BuildContext context, int pageIndex, double pageHeight) =>
      Consumer<RangeProvider>(
        builder: (context, provider, _) => GestureDetector(
          child: Container(
            child: super.buildPage(context, pageIndex, pageHeight),
            foregroundDecoration: BoxDecoration(
                color: provider.isInRange(pageIndex) ? null : Colors.black38),
          ),
          onDoubleTap: () {
            if (provider.startIndex == null) {
              provider.startIndex = pageIndex;
            } else if (provider.endIndex == null) {
              provider.endIndex = pageIndex + 1;
            } else {
              provider._endIndex = null;
              provider.startIndex = pageIndex;
            }
          },
        ),
      );
}

class RangeProvider extends ChangeNotifier {
  int _startIndex;
  int _endIndex;

  int get startIndex => _startIndex;
  int get endIndex => _endIndex;

  set startIndex(int v) {
    _startIndex = v;
    notifyListeners();
  }

  set endIndex(int v) {
    _endIndex = v;
    notifyListeners();
  }

  bool isInRange(int i) {
    if (startIndex == null) return true;
    if (endIndex == null) return startIndex <= i;
    return startIndex <= i && i < endIndex;
  }
}
