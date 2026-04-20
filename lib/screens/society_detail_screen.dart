import 'package:flutter/material.dart';
import '../models/society.dart';
import '../theme/colours.dart';
import '../theme/text_styles.dart';

class SocietyDetailScreen extends StatelessWidget {
  final Society society;
  const SocietyDetailScreen({Key? key, required this.society})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(society.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(society.description, style: AppTextStyles.bodyRegular),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      color: AppColours.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(society.contactEmail, style: AppTextStyles.bodyGrey),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: AppColours.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(society.contactName, style: AppTextStyles.bodyGrey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
