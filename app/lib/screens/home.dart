import 'package:flutter/material.dart';
import 'package:projetus_cloud/widgets/buttons/target_button.dart';
import 'package:projetus_cloud/widgets/others/logo_box.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LogoBox(),
          SizedBox(height: 25),
          Text(
            'Escolha um meio de acesso',
            style: TextStyle(
              fontSize: 30
            )
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TargetButton(AccessContext.host),
              SizedBox(width: 25),
              TargetButton(AccessContext.user)
            ]
          )
        ]
      )
    );
  }
}