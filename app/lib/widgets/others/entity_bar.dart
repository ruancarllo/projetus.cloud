import 'package:flutter/material.dart';

class EntityBar extends StatelessWidget {
  final String name;
  final IconData iconData;
  final Function() click;

  const EntityBar({super.key, required this.name, required this.iconData, required this.click});

  @override Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => click(),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor
        ),
        label: Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black
          ),
        ),
        icon: Icon(
          iconData,
          size: 25,
          color: Theme.of(context).highlightColor,
        )
      )
    );          
  }
}