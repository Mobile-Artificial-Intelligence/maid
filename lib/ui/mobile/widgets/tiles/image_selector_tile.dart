import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:maid_ui/maid_ui.dart';

class ImageSelectorTile extends StatelessWidget {
  final Future<File> image;

  const ImageSelectorTile({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Image selector tile',
      hint: 'Tap to select image',
      image: true,
      button: true,
      child: GestureDetector(
          onTap: () {
          final user = context.read<User>();
          user.profile = image;
        },
        child: GridTile(
          child: FutureTileImage(
            image: image,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      )
    );
  }
}