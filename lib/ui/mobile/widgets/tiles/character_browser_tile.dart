import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/logger.dart';
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FutureBuilder<File>(
          future: widget.character.profile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Icon(Icons.error);
              } else {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.character.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.character.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            } else {
              return const CircularProgressIndicator();
            }
          }
        )
      ),
      onTap: () {
        context.read<Character>().from(widget.character);
      },
      onSecondaryTapUp: (details) => _onSecondaryTapUp(details, context),
      onLongPressStart: (details) => _onLongPressStart(details, context),
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
          onTap: widget.onDelete,
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          child: const Text('Rename'),
          onTap: () {
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
                setState(() {
                  String oldName = widget.character.name;
                  Logger.log(
                      "Updating character $oldName ====> ${controller.text}");
                  widget.character.name = controller.text;
                });
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
  }
}
