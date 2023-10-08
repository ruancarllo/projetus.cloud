import 'package:flutter/material.dart';
import 'package:projetus_cloud/shared/composer.dart';

class LogoBox extends StatelessWidget {
  const LogoBox({super.key});

  @override Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 150,
      child: GestureDetector(
        onDoubleTap: () => Composer.resetMetadata(),
        child: Image.asset('assets/icons/full.png')
      )
    );
  }
}