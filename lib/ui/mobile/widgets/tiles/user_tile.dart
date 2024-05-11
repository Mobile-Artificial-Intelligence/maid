import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/widgets/tiles/image_selector_tile.dart';
import 'package:provider/provider.dart';
import 'package:maid_ui/maid_ui.dart';

class UserTile extends StatefulWidget {
  const UserTile({super.key});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  final iconButtonKey = GlobalKey();

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
          leading: FutureAvatar(
            key: user.key,
            image: user.profile,
            radius: 20,
          ),
          trailing: IconButton(
            key: iconButtonKey,
            icon: const Icon(Icons.more_vert),
            onPressed: onPressed,
          ),
        );
      },
    );
  }

  void onPressed() {
    final RenderBox renderBox = iconButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx,
        offset.dy,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            title: const Text("Rename"),
            onTap: () {
              Navigator.pop(context); // Close the menu first
              showRenameDialog(context);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text("Change Picture"),
            onTap: () {
              Navigator.pop(context); // Close the menu first
              showImageDialog(context);
            },
          ),
        ),
      ]
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
              content: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                shrinkWrap: true,
                children: [
                  ImageSelectorTile(
                    image: Utilities.fileFromAssetImage("chadUser.png")
                  ),
                  ImageSelectorTile(
                    image: Utilities.fileFromAssetImage("thadUser.png")
                  ),
                  ImageSelectorTile(
                    image: Utilities.fileFromAssetImage("eugeneUser.png")
                  ),
                  ImageSelectorTile(
                    image: User.customImageFuture
                  ),
                ]
              ),
              actions: [
                FilledButton(
                  onPressed: user.loadImage,
                  child: Text(
                    "Load Custom",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Close",
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
