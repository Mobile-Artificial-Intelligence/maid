import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/widgets/chat_widgets/chat_branch_switcher.dart';
import 'package:maid/ui/mobile/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/shaders/blade_runner_gradient.dart';
import 'package:maid_llm/chat_node.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';

import 'package:maid_ui/maid_ui.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatefulWidget {
  final String hash;

  const ChatMessage({
    super.key,
    required this.hash,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> with SingleTickerProviderStateMixin {
  late ChatNode node;
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer3<Session, User, Character>(
      builder: (context, session, user, character, child) {
        node = session.chat.find(widget.hash)!;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    color: Colors
                        .white, // This color is needed, but it will be overridden by the shader.
                    fontSize: 20,
                  ),
                )
              ),
              const Expanded(child: SizedBox()), // Spacer
              if (node.finalised) ...messageOptions(),
              ChatBranchSwitcher(hash: widget.hash)
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: editing ? editingColumn() : chatColumn(),
            )
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
        onPressed: onEdit,
        icon: const Icon(Icons.edit),
      ),
    ];
  }

  List<Widget> assistantOptions() {
    return [
      IconButton(
        onPressed: onRegenerate,
        icon: const Icon(Icons.refresh),
      ),
    ];
  }

  void onRegenerate() {
    if (!context.read<Session>().chat.tail.finalised) return;

    if (context.read<Session>().model.missingRequirements.isNotEmpty) {
      showMissingRequirementsDialog(context);
    } else {
      context.read<Session>().regenerate(node.hash, context);
      setState(() {});
    }
  }

  List<Widget> editingColumn() {
    final messageController = TextEditingController(text: node.content);

    return [
      TextField(
        controller: messageController,
        autofocus: true,
        cursorColor: Theme.of(context).colorScheme.secondary,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: "Edit Message",
          fillColor: Theme.of(context).colorScheme.background,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
      Row(children: [
        IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => onEditingDone(messageController.text),
          icon: const Icon(Icons.done)
        ),
        IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: onEditingCancel,
          icon: const Icon(Icons.close)
        )
      ])
    ];
  }

  List<Widget> chatColumn() {
    return [
      if (!node.finalised && node.content.isEmpty)
        const TypingIndicator()
      else
        messageBuilder(node.content),
    ];
  }

  Widget messageBuilder(String message) {
    List<Widget> widgets = [];
    List<String> parts = message.split('```');

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 0) {
        widgets.add(SelectableText(part, style: TextStyle(
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
    if (!context.read<Session>().chat.tail.finalised) return;
          
    if (context.read<Session>().model.missingRequirements.isNotEmpty) {
      showMissingRequirementsDialog(context);
    }
    else {
      setState(() {
        editing = true;
      });
    }
  }

  void onEditingDone(String newText) {
    if (!context.read<Session>().chat.tail.finalised) return;

    if (context.read<Session>().model.missingRequirements.isNotEmpty) {
      showMissingRequirementsDialog(context);
    } 
    else {
      setState(() {
        editing = false;
      });
      context.read<Session>().edit(node.hash, newText, context);
    }
  }

  void onEditingCancel() {
    setState(() {
      editing = false;
    });
  }
}
