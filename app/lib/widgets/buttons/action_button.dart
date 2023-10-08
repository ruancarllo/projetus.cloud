import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String actionName;
  final Function() action;

  const ActionButton({super.key, required this.actionName, required this.action});

  @override Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => action(),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        padding: const EdgeInsets.all(18),
        backgroundColor: Theme.of(context).highlightColor,
      ),
      child: Text(
        actionName,
        style: const TextStyle(
          fontSize: 15,
        ),
      )
    );
  }
}