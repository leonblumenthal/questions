import 'package:flutter/material.dart';

class Utils {
  /// Get current date as [DateTime].
  static DateTime getDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Function boolDialogBuilder(
    String title,
    String content, {
    String negative = 'No',
    String positive = 'Yes',
  }) =>
      (BuildContext context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text(negative),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(positive),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          );

  static Function stringDialogBuilder(
    String title, {
    String negative = 'Cancel',
    String positive = 'Ok',
  }) =>
      (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: Container(
            child: TextField(
              controller: controller,
              maxLines: 1,
              style: const TextStyle(fontSize: 16),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            width: 1000,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(negative),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text(positive),
              onPressed: () => Navigator.of(context).pop(controller.text),
            )
          ],
        );
      };
}
