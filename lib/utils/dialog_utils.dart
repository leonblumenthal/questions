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
        actions: [
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
