import 'package:flutter/material.dart';

class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({super.key, this.size = 148, this.bottomSpacing = 16});

  final double size;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
