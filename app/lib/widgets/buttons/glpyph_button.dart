import 'package:flutter/material.dart';

class GlyphButton extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final Function() action;

  const GlyphButton({super.key, required this.iconData, required this.iconColor, required this.action});

  @override Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => action(),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(35, 35),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor
      ),
      child: Icon(
        iconData,
        size: 25,
        color: iconColor
      )
    );
  }
}