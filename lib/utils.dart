import 'package:flutter/material.dart';

class Utils {
  /// Get current date as [DateTime].
  static DateTime getDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns a function that builds a dialog with the given paramters.
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
}
