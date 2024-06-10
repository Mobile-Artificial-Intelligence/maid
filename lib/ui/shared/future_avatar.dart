import 'dart:io';

import 'package:flutter/material.dart';

class FutureAvatar extends StatelessWidget {
  final Future<File> image;
  final double? radius;

  // Static cache map
  static final Map<Key, File> _cache = {};

  const FutureAvatar({required super.key, required this.image, this.radius});

  @override
  Widget build(BuildContext context) {
    // Check if the image is already cached
    final cachedImage = _cache[key!];

    if (cachedImage != null) {
      return CircleAvatar(
        backgroundImage: FileImage(cachedImage),
        radius: radius,
      );
    }
    else {
      return FutureBuilder<File>(
        future: image,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Icon(Icons.error);
            } else {
              _cache[key!] = snapshot.data!;

              return CircleAvatar(
                backgroundImage: FileImage(snapshot.data!),
                radius: radius,
              );
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    }
  }
}