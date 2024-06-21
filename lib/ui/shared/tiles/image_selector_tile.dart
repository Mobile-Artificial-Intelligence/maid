import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/ui/shared/utilities/future_tile_image.dart';

class ImageSelectorTile extends StatelessWidget {
  final Future<File> image;

  const ImageSelectorTile({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.black.withOpacity(0.1),
        highlightColor: Colors.black.withOpacity(0.2),
        splashColor: Colors.black.withOpacity(0.2),
        onTap: () {
          final user = User.of(context);
          user.profile = image;
          user.save();
        },
        child: FutureTileImage(
          key: key ?? UniqueKey(),
          image: image,
          borderRadius: BorderRadius.circular(10),
        ),
      )
    );
  }
}