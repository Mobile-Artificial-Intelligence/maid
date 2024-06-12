import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/widgets/tiles/image_selector_tile.dart';
import 'package:maid/ui/shared/widgets/future_avatar.dart';
import 'package:provider/provider.dart';

class UserTile extends StatefulWidget {
  const UserTile({super.key});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: listTileBuilder,
    );
  }

  Widget listTileBuilder(BuildContext context, User user, Widget? child) {
    return ListTile(
      title: Text(
        user.name,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20,
        ),
      ),
      leading: FutureAvatar(
        key: user.key,
        image: user.profile,
        radius: 20,
      ),
      trailing: PopupMenuButton(
        tooltip: 'User Menu',
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            child: const Text("Rename"),
            onTap: () {
              Navigator.pop(context); // Close the menu first
              showRenameDialog(context);
            },
          ),
          PopupMenuItem(
            child: const Text("Change Picture"),
            onTap: () {
              Navigator.pop(context); // Close the menu first
              showImageDialog(context);
            },
          ),
        ]
      ),
    );
  }

  void showRenameDialog(BuildContext context) {
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
                  child: const Text(
                    "Cancel"
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    user.name = controller.text;
                    user.save();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Rename"
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showImageDialog(BuildContext context) {
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
              content: SizedBox(
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
              ),
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
          },
        );
      },
    );
  }
}
