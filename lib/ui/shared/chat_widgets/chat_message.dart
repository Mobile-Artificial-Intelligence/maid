import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid/enumerators/chat_role.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/dialogs/missing_requirements_dialog.dart';
import 'package:maid/ui/shared/shaders/blade_runner_gradient_shader.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/ui/shared/shaders/wave_gradient_shader.dart';
import 'package:maid/ui/shared/utilities/code_box.dart';
import 'package:maid/ui/shared/utilities/future_avatar.dart';
import 'package:provider/provider.dart';

class ChatMessageWidget extends StatefulWidget {
  final String hash;

  const ChatMessageWidget({
    super.key,
    required this.hash,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> with SingleTickerProviderStateMixin {
  late ChatNode node;
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppData, User>(
      builder: (context, appData, user, child) {
        final session = appData.currentSession;
        final character = appData.currentCharacter;

        node = session.chat.find(widget.hash)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10.0),
                FutureAvatar(
                  key: node.role == ChatRole.user ? user.key : character.key,
                  image: node.role == ChatRole.user ? user.profile : character.profile,
                  radius: 16,
                ),
                const SizedBox(width: 10.0),
                BladeRunnerGradientShader(
                  stops: const [0.5, 0.85],
                  child: Text(
                    node.role == ChatRole.user ? user.name : character.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )
                ),
                const Expanded(child: SizedBox()), // Spacer
                if (node.finalised) ...messageOptions(),
                branchSwitcher()
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: editing ? editingColumn() : chatColumn()
            )
          ]
        );
      },
    );
  }

  List<Widget> messageOptions() {
    return node.role == ChatRole.user ? userOptions() : assistantOptions();
  }

  List<Widget> userOptions() {
    return [
      IconButton(
        tooltip: 'Edit Message',
        onPressed: onEdit,
        icon: const Icon(Icons.edit),
      ),
    ];
  }

  List<Widget> assistantOptions() {
    return [
      IconButton(
        tooltip: 'Regenerate Response',
        onPressed: onRegenerate,
        icon: const Icon(Icons.refresh),
      ),
    ];
  }

  void onRegenerate() {
    final session = Session.of(context);

    if (!session.chat.tail.finalised) return;

    if (session.model.missingRequirements.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const MissingRequirementsDialog();
        }
      );
    } else {
      session.regenerate(node.hash, context);
      setState(() {});
    }
  }

  Widget editingColumn() {
    final messageController = TextEditingController(text: node.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: messageController,
          autofocus: true,
          cursorColor: Theme.of(context).colorScheme.secondary,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: "Edit Message",
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'Approve Edit',
              padding: const EdgeInsets.all(0),
              onPressed: () => onEditingDone(messageController.text),
              icon: const Icon(Icons.done)
            ),
            IconButton(
              tooltip: 'Cancel Edit',
              padding: const EdgeInsets.all(0),
              onPressed: onEditingCancel,
              icon: const Icon(Icons.close)
            )
          ]
        )
      ]
    );
  }

  Widget branchSwitcher() {
    return Consumer<AppData>(
      builder: (BuildContext context, AppData appData, Widget? child) {
        final session = appData.currentSession;
        
        int currentIndex = session.chat.indexOf(widget.hash);
        int siblingCount = session.chat.siblingCountOf(widget.hash);

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: 'Previous chat branch',
              padding: const EdgeInsets.all(0),
              onPressed: () {
                if (!session.chat.tail.finalised) return;
                session.chat.last(widget.hash);
                session.notify();
              },
              icon: Icon(
                Icons.arrow_left,
                color: Theme.of(context).colorScheme.onPrimary
              )
            ),
            Text(
              '${currentIndex + 1}/$siblingCount',
              style: Theme.of(context).textTheme.labelLarge,
              semanticsLabel: 'Chat branch ${currentIndex + 1} of $siblingCount',
            ),
            IconButton(
              tooltip: 'Next chat branch',
              padding: const EdgeInsets.all(0),
              onPressed: () {
                if (!session.chat.tail.finalised) return;
                session.chat.next(widget.hash);
                session.notify();
              },
              icon: Icon(
                Icons.arrow_right,
                color: Theme.of(context).colorScheme.onPrimary
              ),
            ),
          ],
        );
      },
    );
  }

  Widget chatColumn() {
    if (!node.finalised && node.content.isEmpty) {
      return buildTypingIndicator();
    } 
    else {
      return messageBuilder(node.content);
    }
  }

  Widget buildTypingIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildTypingIndicatorBar(Random().nextInt(4) + 1),
        buildTypingIndicatorBar(Random().nextInt(4) + 1),
        buildTypingIndicatorBar(50 + Random().nextInt(4) + 1),
      ],
    );
  }

  Widget buildTypingIndicatorBar(int flex) {
    double durationFactor = (100 - flex) / 100.0;
    double animationOffset = Random().nextDouble();
  
    return Row(
      children: [
        Expanded(
          flex: 100 - flex,
          child: WaveGradientShader(
            durationFactor: durationFactor,
            animationOffset: animationOffset,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Spacer(
          flex: flex,
        ),
      ],
    );
  }

  Widget messageBuilder(String message) {
    List<Widget> widgets = [];
    List<String> parts = message.split('```');

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 0) {
        widgets.add(
          SelectableText(
            part, 
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
            )
          )
        );
      } else {
        widgets.addAll([
          const SizedBox(height: 10),
          CodeBox(code: part), // Assuming CodeBox is a widget you've defined for displaying code.
          const SizedBox(height: 10),
        ]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  void onEdit() {
    final session = Session.of(context);

    if (!session.chat.tail.finalised) return;
          
    if (session.model.missingRequirements.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const MissingRequirementsDialog();
        }
      );
    }
    else {
      setState(() {
        editing = true;
      });
    }
  }

  void onEditingDone(String newText) {
    final session = Session.of(context);

    if (!session.chat.tail.finalised) return;

    if (session.model.missingRequirements.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const MissingRequirementsDialog();
        }
      );
    } 
    else {
      setState(() {
        editing = false;
      });
      session.edit(node.hash, newText, context);
    }
  }

  void onEditingCancel() {
    setState(() {
      editing = false;
    });
  }
}
