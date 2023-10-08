import 'package:flutter/material.dart';

class PromptDialog extends StatelessWidget {
  final String message;
  final Function(String value) apply;

  const PromptDialog({super.key, required this.apply, required this.message});

  @override Widget build(BuildContext context) {
    String result = '';

    return AlertDialog(
      title: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25
        ),
      ),
      content: TextField(
        onChanged: (value) => result = value,
        style: const TextStyle(
          fontSize: 20
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: ElevatedButton(
            onPressed: () {
              if (result != '') {
                apply(result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green
            ),
            child: const Text(
              'Criar',
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
              'Cancelar',
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