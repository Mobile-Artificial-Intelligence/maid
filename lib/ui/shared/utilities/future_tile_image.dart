import 'dart:io';

import 'package:flutter/material.dart';

class FutureTileImage extends StatelessWidget {
  final Future<File> image;
  final BorderRadius? borderRadius;

  const FutureTileImage({required super.key, required this.image, this.borderRadius});

  static final Map<Key, File> _cache = {};

  @override
  Widget build(BuildContext context) {
    final cachedImage = _cache[key!];

    if (cachedImage != null) {
      return buildImage(cachedImage);
    }

    return FutureBuilder<File>(
      future: image, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Icon(Icons.error);
          } else {
            _cache[key!] = snapshot.data!;

            return buildImage(snapshot.data!);
          }
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }

  Widget buildImage(File file) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.file(
        file,
        fit: BoxFit.cover,
      ),
    );
  }
}