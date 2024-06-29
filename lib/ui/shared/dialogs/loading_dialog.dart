import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String title;

  const LoadingDialog({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
       title,
        textAlign: TextAlign.center
      ),
      content: const Center(
        heightFactor: 1.0,
        child: CircularProgressIndicator()
      )
    );
  }
}