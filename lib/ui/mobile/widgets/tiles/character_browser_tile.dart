import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/utilities.dart';
import 'package:provider/provider.dart';

class CharacterBrowserTile extends StatefulWidget {
  final Character character;
  final void Function() onDelete;

  const CharacterBrowserTile(
      {super.key, required this.character, required this.onDelete});

  @override
  State<CharacterBrowserTile> createState() => _CharacterBrowserTileState();
}

class _CharacterBrowserTileState extends State<CharacterBrowserTile> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<Character, User>(
      builder: (context, character, user, child) {
        selected = character.key == widget.character.key;

        return GestureDetector(
          child: ListTile(
              tileColor: Theme.of(context).colorScheme.primary,
              selectedTileColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.25),
              textColor: Colors.white,
              selectedColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              // Square image with rounded corners of the character
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(
                    10.0), // Adjust the corner radius here
                child: Image(
                  image: Image.file(widget.character.profile).image,
                  width: 50, // Adjust the size as needed
                  height: 50,
                  fit: BoxFit
                      .cover, // This ensures the image covers the square area
                ),
              ),
              minLeadingWidth: 60,
              title: Column(children: [
                Text(widget.character.name),
                const SizedBox(height: 10.0),
                Text(
                  Utilities.formatPlaceholders(widget.character.description,
                      user.name, widget.character.name),
                  style: const TextStyle(fontSize: 12.0),
                ),
              ]),
              selected: selected),
          onTap: () {
            character.from(widget.character);
          },
          onSecondaryTapUp: (details) => _onSecondaryTapUp(details, context),
          onLongPressStart: (details) => _onLongPressStart(details, context),
        );
      },
    );
  }

  void _onSecondaryTapUp(TapUpDetails details, BuildContext context) =>
      _showContextMenu(details.globalPosition, context);

  void _onLongPressStart(LongPressStartDetails details, BuildContext context) =>
      _showContextMenu(details.globalPosition, context);

  void _showContextMenu(Offset position, BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final TextEditingController controller =
        TextEditingController(text: widget.character.name);

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text('Delete'),
          onTap: () {
            Navigator.of(context).pop(); // Close the menu first
            widget.onDelete();
          },
        ),
        PopupMenuItem(
          child: const Text('Rename'),
          onTap: () {
            Navigator.of(context).pop(); // Close the menu first
            // Delayed execution to allow the popup menu to close properly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showRenameDialog(context, controller);
            });
          },
        ),
      ],
    );
  }

  void _showRenameDialog(
      BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Rename Session",
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
                String oldName = widget.character.name;
                Logger.log(
                    "Updating character $oldName ====> ${controller.text}");
                widget.character.name = controller.text;
                Navigator.of(context).pop();
                setState(() {});
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
  }
}
