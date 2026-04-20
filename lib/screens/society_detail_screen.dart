import 'package:flutter/material.dart';
import '../models/society.dart';
import '../theme/colours.dart';

class SocietyDetailScreen extends StatelessWidget {
  final Society society;
  const SocietyDetailScreen({Key? key, required this.society})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(society.name)),
      body: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: AppColours.primaryPurple,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(24),
            child: Text(
              society.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
