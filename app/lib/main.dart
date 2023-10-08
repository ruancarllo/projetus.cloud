import 'package:flutter/material.dart';
import 'package:projetus_cloud/screens/home.dart';
import 'package:projetus_cloud/screens/host.dart';
import 'package:projetus_cloud/screens/user.dart';

void main() {
  const application = Application();
  runApp(application);
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projetus.cloud',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/host': (context) => const HostScreen(),
        '/user': (context) => const UserScreen(),
      },
      initialRoute: '/home',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 45, 110, 220),
        highlightColor: const Color.fromARGB(255, 0, 165, 230)
      )
    );
  }
}