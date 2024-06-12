import 'dart:io';

import 'package:flutter/material.dart';

class FutureTileImage extends StatelessWidget {
  final Future<File> image;
  final BorderRadius? borderRadius;

  const FutureTileImage({super.key, required this.image, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: image, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Icon(Icons.error);
          } else {
            return ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
            ),
          );
          }
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}