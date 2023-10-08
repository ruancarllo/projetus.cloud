import 'package:flutter/material.dart';

class TargetButton extends StatelessWidget {
  final AccessContext accessContext;
  
  const TargetButton(this.accessContext, {super.key});

  @override Widget build(BuildContext context) {
    late String contextName;
    late String routeName;
    late IconData iconData;

    if (accessContext == AccessContext.host) {
      contextName = 'Servidor';
      routeName = '/host';
      iconData = Icons.dns;
    }

    if (accessContext == AccessContext.user) {
      contextName = 'Cliente';
      routeName = '/user';
      iconData = Icons.computer;
    }

    return SizedBox(
      width: 190,
      height: 190,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, routeName),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          padding: const EdgeInsets.all(25),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 90
            ),
            const SizedBox(height: 10),
            Text(
              contextName,
              style: const TextStyle(
                fontSize: 25
              )
            )
          ]
        )
      )
    );
  }
}

enum AccessContext {
  host,
  user
}