import 'package:flutter/material.dart';

class AppBarTextField extends StatelessWidget {

  final TextEditingController controller;
  final void Function(String) onSubmitted;

  AppBarTextField({this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        cursorColor: Colors.white,
        decoration: const InputDecoration(border: InputBorder.none),
        autofocus: controller.text.isEmpty,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: onSubmitted,
      );
}
