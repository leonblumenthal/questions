import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:questions/constants.dart';
import 'package:questions/utils/utils.dart';

/// Widget for showing document pages and
/// scrolling to an inital page offset.
///
/// Override [buildPage] and [getExtraScrollOffset]
/// to add additional functionality.
class DocumentScreen extends StatelessWidget {
  final String title;
  final PdfDocument document;
  final Color color;
  final double pageOffset;

  final Map<int, Future<PdfPageImage>> pageImageFutures = {};

  DocumentScreen(
    this.title,
    this.document,
    this.color, {
    this.pageOffset = 0,
  }) {
    var i = pageOffset.toInt();
    pageImageFutures[i] = loadPageImage(document, i);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder(
          future: pageImageFutures[pageOffset.toInt()],
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              PdfPageImage pageImage = snapshot.data;

              var ratio = pageImage.width / pageImage.height;
              var size = MediaQuery.of(context).size;
              var pageHeight = size.width / ratio;

              var scrollOffset = Constants.appBarHeight +
                  pageOffset * pageHeight -
                  size.height / 3 +
                  getExtraScrollOffset(pageOffset.toInt());

              if (scrollOffset <= Constants.appBarHeight) scrollOffset = 0;

              return _buildScrollView(scrollOffset, pageHeight);
            }
            return Container();
          },
        ),
      );

  /// Override this to account for changed page height
  /// caused by overriden [buildPageWidget] method.
  double getExtraScrollOffset(int pageIndex) => 0;

  Widget _buildScrollView(double scrollOffset, double pageHeight) =>
      CustomScrollView(
        controller: ScrollController(initialScrollOffset: scrollOffset),
        slivers: [
          SliverAppBar(
            title: Text(title),
            floating: true,
            snap: true,
            backgroundColor: color,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => buildPage(context, i, pageHeight),
              childCount: document.pageCount,
            ),
          ),
        ],
      );

  /// Override this to alter the page widget.
  /// Don't forget to to alter [getExtraScrollOffset] if height is altered.
  Widget buildPage(BuildContext context, int pageIndex, double pageHeight) =>
      SizedBox(
        height: pageHeight,
        child: FutureBuilder(
          future: pageImageFutures.putIfAbsent(
            pageIndex,
            () => loadPageImage(document, pageIndex),
          ),
          builder: (_, snapshot) {
            if (snapshot.hasData) return RawImage(image: snapshot.data.image);
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
}
