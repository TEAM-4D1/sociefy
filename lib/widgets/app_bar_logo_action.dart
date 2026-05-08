import 'package:flutter/material.dart';

class AppBarLogoAction extends StatelessWidget {
  const AppBarLogoAction({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Image.asset(
            'assets/setap logo for vs code.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
