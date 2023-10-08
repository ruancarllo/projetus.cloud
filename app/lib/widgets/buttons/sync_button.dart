import 'package:flutter/material.dart';

class SyncButton extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final String text;
  final Function() action;

  const SyncButton({super.key, required this.iconData, required this.color, required this.text, required this.action});

  @override Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: ElevatedButton(
        onPressed: () => action(),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35)
          ),
          padding: const EdgeInsets.all(35),
          backgroundColor: color,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 150
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 25
              ),
              textAlign: TextAlign.center,
            )
          ]
        )
      )
    );
  }
}