import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:maid/classes/static/logger.dart';

class CharacterTile extends StatefulWidget {
  final Character character;
  final bool? isSelected;

  const CharacterTile({super.key, required this.character, this.isSelected});

  @override
  State<CharacterTile> createState() => _CharacterTileState();
}

class _CharacterTileState extends State<CharacterTile> {
  Timer? longPressTimer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        buildImageContainer(),
        buildTick(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            hoverColor: Colors.black.withOpacity(0.1),
            highlightColor: Colors.black.withOpacity(0.2),
            splashColor: Colors.black.withOpacity(0.2),
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            onSecondaryTapUp: (details) => showContextMenu(details.globalPosition),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: buildTextColumn(),
            )
          ),
        ),
      ],
    );
  }

  Widget buildTick() {
    if (widget.isSelected ?? false) {
      return const Positioned(
        top: 10,
        right: 10,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildTextColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
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
    );
  }

  Widget buildImageContainer() {
    return Container(
      padding: const EdgeInsets.all(1),
      margin: const EdgeInsets.all(4),
      foregroundDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.center,
          colors: [Colors.black, Colors.transparent],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: buildImage(),
      ),
    );
  }

  Widget buildImage() {
    return FutureBuilder<File>(
      future: widget.character.profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Icon(Icons.error);
          } else {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  void onTapDown(TapDownDetails details) {
    longPressTimer = Timer(const Duration(seconds: 1), () {
      showContextMenu(details.globalPosition);
    });
  }

  void onTapUp(TapUpDetails details) {
    if (longPressTimer?.isActive ?? false) {
      longPressTimer?.cancel();
      CharacterCollection.of(context).current = widget.character;
      
      if (AppPreferences.of(context).isDesktop) {
        DesktopNavigator.of(context).navigateSidePanel('/character');
      } 
      else {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, '/character');
      }
    }
  }

  void showContextMenu(Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final TextEditingController controller = TextEditingController(text: widget.character.name);

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () {
            CharacterCollection.of(context).removeCharacter(widget.character);
          },
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

  void _showRenameDialog(BuildContext context, TextEditingController controller) {
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
