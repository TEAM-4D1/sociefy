import 'package:flutter/material.dart';

class AppBarLogoAction extends StatelessWidget {
  const AppBarLogoAction({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/setap logo for vs code.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
