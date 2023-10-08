import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String message;
  final String description;
  final Function() action;

  const ConfirmDialog({super.key, required this.message, required this.description, required this.action});

  @override Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25
        ),
      ),
      content: Text(
        description,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20
        ),
      ),
      icon: Icon(
        Icons.warning_rounded,
        size: 80,
        color: Colors.yellow.shade800,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: ElevatedButton(
            onPressed: () => action(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green
            ),
            child: const Text(
              'Sim',
              style: TextStyle(
                fontSize: 20
              )
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 10, 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red
            ),
            child: const Text(
              'Não',
              style: TextStyle(
                fontSize: 20
              )
            )
          )
        )
      ]
    );                 
  }
}