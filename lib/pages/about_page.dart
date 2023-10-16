import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
          Navigator.of(context).pop();
        },),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: const Text('About'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10.0),
            Text(
              'Maid',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ]
        ),
      ),
    );
  }
}
