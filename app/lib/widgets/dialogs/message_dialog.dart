import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String message;
  final IconData iconData;

  const MessageDialog({super.key, required this.message, required this.iconData});

  @override Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        message,
        style: const TextStyle(
          fontSize: 25
        ),
        textAlign: TextAlign.center,
      ),
      icon: Icon(
        iconData,
        size: 80,
        color: Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      )
    );
  }
}