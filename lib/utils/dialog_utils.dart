import 'package:flutter/material.dart';

AlertDialog Function(BuildContext) boolDialogBuilder(
  String title,
  String content, {
  String negative = 'No',
  String positive = 'Yes',
}) =>
    (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            FlatButton(
              child: Text(negative),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(positive),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        );

AlertDialog Function(BuildContext) stringDialogBuilder(
  String title, {
  String negative = 'Cancel',
  String positive = 'Ok',
}) =>
    (context) {
      var controller = TextEditingController();
      var popText = () => Navigator.of(context).pop(controller.text);
      return AlertDialog(
        title: Text(title),
        content: Container(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => popText(),
            maxLines: 1,
            style: const TextStyle(fontSize: 16),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          width: 1000,
        ),
        actions: [
          FlatButton(
            child: Text(negative),
            onPressed: Navigator.of(context).pop,
          ),
          FlatButton(
            child: Text(positive),
            onPressed: popText,
          )
        ],
      );
    };

AlertDialog Function(BuildContext) colorDialogBuilder(
  String title,
  List<Color> colors,
) =>
    (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              for (var c in colors)
                ButtonTheme(
                  minWidth: 48,
                  height: 48,
                  buttonColor: c,
                  shape: const CircleBorder(),
                  child: RaisedButton(
                    onPressed: () => Navigator.of(context).pop(c),
                  ),
                )
            ],
          ),
        ));
