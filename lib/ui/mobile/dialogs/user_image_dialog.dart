import 'package:flutter/material.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:maid/ui/shared/tiles/image_selector_tile.dart';
import 'package:provider/provider.dart';

class UserImageDialog extends StatelessWidget {
  const UserImageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: dialogBuilder,
    );
  }

  Widget dialogBuilder(BuildContext context, User user, Widget? child) {
    return AlertDialog(
      title: const Text(
        "Change Profile Picture",
        textAlign: TextAlign.center,
      ),
      content: buildContent(context, user),
      actions: [
        FilledButton(
          onPressed: user.loadImage,
          child: const Text(
            "Load Custom"
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Close"
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget buildContent(BuildContext context, User user) {
    return SizedBox(
      width: 300,
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        shrinkWrap: true,
        children: [
          ImageSelectorTile(
            image: Utilities.fileFromAssetImage("chadUser.png"),
          ),
          ImageSelectorTile(
            image: Utilities.fileFromAssetImage("thadUser.png"),
          ),
          ImageSelectorTile(
            image: Utilities.fileFromAssetImage("eugeneUser.png"),
          ),
          ImageSelectorTile(
            image: User.customImageFuture,
          ),
        ],
      ),
    );
  }
}