import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/ui/shared/widgets/future_tile_image.dart';

class ImageSelectorTile extends StatelessWidget {
  final Future<File> image;

  const ImageSelectorTile({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final user = User.of(context);
        user.profile = image;
        user.save();
      },
      child: GridTile(
        child: FutureTileImage(
          image: image,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}