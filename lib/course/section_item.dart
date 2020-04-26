import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questions/course/course_provider.dart';
import 'package:questions/models.dart';
import 'package:questions/section/section_screen.dart';

class SectionItem extends StatelessWidget {
  final Section section;
  final Color color;

  SectionItem(this.section, this.color);

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildTitle(),
                  if (section.document == null) _buildNoDocumentIcon()
                ],
              )),
          onTap: () => _goToSection(context),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  Widget _buildTitle() => Expanded(
        child: Text(
          '${section.order + 1}. ${section.title}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );

  void _goToSection(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SectionScreen(section, color),
    ));
    Provider.of<CourseProvider>(context).reload();
  }

  Widget _buildNoDocumentIcon() => const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(Icons.location_off, size: 16, color: Colors.grey),
      );
}
