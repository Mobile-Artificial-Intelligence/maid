import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:provider/provider.dart';

class ImageSelectorTile extends StatelessWidget {
  final File image;

  const ImageSelectorTile({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final user = context.read<User>();
        user.profile = image;
      },
      child: GridTile(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        )
      ),
    );
  }
}