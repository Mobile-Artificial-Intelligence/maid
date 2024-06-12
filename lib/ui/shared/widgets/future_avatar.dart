import 'dart:io';

import 'package:flutter/material.dart';

class FutureAvatar extends StatelessWidget {
  final String? tooltip;
  final Future<File> image;
  final double? radius;
  final void Function()? onPressed;

  // Static cache map
  static final Map<Key, File> _cache = {};

  const FutureAvatar({required super.key, required this.image, this.radius, this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip ?? 'Avatar',
      button: onPressed != null,
      child: onPressed != null ? 
        buildButton(context) : 
        buildAvatar(context),
    );
  }

  Widget buildButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      width: radius != null ? radius! * 2 : 48.0,
      height: radius != null ? radius! * 2 : 48.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          buildAvatar(context),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              hoverColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              splashColor: Colors.white.withOpacity(0.2),
              onTap: onPressed
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatar(BuildContext context) {
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