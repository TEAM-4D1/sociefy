import 'package:flutter/material.dart';

class SocietiesScreen extends StatelessWidget {
  const SocietiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Societies')),
      body: const Center(
        child: Text('Loading...'),
      ),
    );
  }
}
