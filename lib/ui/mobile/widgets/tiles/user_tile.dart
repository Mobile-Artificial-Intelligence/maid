import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/ui/mobile/widgets/tiles/image_selector_tile.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        return ListTile(
          title: Text(
            user.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20,
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: const AssetImage("assets/chadUser.png"),
            foregroundImage: Image.file(user.profile).image,
            radius: 20,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showRenameDialog(context);
            },
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<User>(
          builder: (context, user, child) {
            final controller = TextEditingController(text: user.name);

            return AlertDialog(
              title: const Text(
                "Rename User",
                textAlign: TextAlign.center,
              ),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Enter new name",
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    user.name = controller.text;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Rename",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<User>(
          builder: (context, user, child) {
            return AlertDialog(
              title: const Text(
                "Change Profile Picture",
                textAlign: TextAlign.center,
              ),
              content: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: [
                  ImageSelectorTile(
                    image: File("assets/chadUser.png")
                  ),
                  ImageSelectorTile(
                    image: File("assets/thadUser.png")
                  ),
                  ImageSelectorTile(
                    image: File("assets/eugeneUser.png")
                  ),
                ]
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
