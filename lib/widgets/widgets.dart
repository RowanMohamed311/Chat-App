import 'package:chat_app/shared/constants.dart';
import 'package:flutter/material.dart';

//* this file for the decoration and styling  of the widgets.
//* if we want to use it jus call the name 'textInputDecoration' and add '.copywith' to add the wanted (specific) properties.

final textInputDecoration = InputDecoration(
  labelStyle:
      TextStyle(color: Constants().secondarycolor, fontWeight: FontWeight.w300),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants().secondarycolor, width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants().primarcolor, width: 2),
  ),
  errorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFB71C1C), width: 2),
  ),
);

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}
