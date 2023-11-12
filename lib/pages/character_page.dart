import 'package:flutter/material.dart';
import 'package:maid/utilities/message_manager.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/utilities/memory_manager.dart';
import 'package:maid/utilities/character.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> { 
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    MemoryManager.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: const Text('Character'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10.0),
                CircleAvatar(
                  backgroundImage: const AssetImage("assets/defaultResponseProfile.png"),
                  foregroundImage: character.profile.image,
                  radius: 75,
                ),
                const SizedBox(height: 20.0),
                Text(
                  character.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20.0),
                DoubleButtonRow(
                  leftText: "Switch Character", 
                  leftOnPressed: () {
                    switcherDialog(
                      context, 
                      MemoryManager.getCharacters, 
                      MemoryManager.setCharacter,
                      MemoryManager.removeCharacter,
                      () => setState(() {}),
                      () async {
                        MemoryManager.save();
                        character = Character();
                        character.name = "New Character";
                        setState(() {});
                      }
                    );
                  }, 
                  rightText: "Reset All", 
                  rightOnPressed: () {
                    character.resetAll();
                    setState(() {});
                  }
                ),
                const SizedBox(height: 15.0),
                DoubleButtonRow(
                  leftText: "Load JSON",
                  leftOnPressed: () async {
                    await storageOperationDialog(context, character.loadCharacterFromJson);
                    setState(() {});
                  },
                  rightText: "Save JSON",
                  rightOnPressed: () async {
                    await storageOperationDialog(context, character.saveCharacterToJson);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20.0),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                ListTile(
                  title: Row(
                    children: [
                      const Expanded(
                        child: Text("Character Name"),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          decoration: const InputDecoration(
                            labelText: "Name",
                          ),
                          controller: TextEditingController(text: character.name),
                          onSubmitted: (value) {
                            if (MemoryManager.getCharacters().contains(value)) {
                              MemoryManager.setCharacter(value);
                            } else if (value.isNotEmpty) {
                              MemoryManager.updateCharacter(value);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                MaidTextField(
                  headingText: 'User alias', 
                  labelText: 'Alias',
                  initialValue: character.userAlias,
                  onChanged: (value) {
                    character.userAlias = value;
                  },
                ),
                MaidTextField(
                  headingText: 'Response alias',
                  labelText: 'Alias',
                  initialValue: character.responseAlias,
                  onChanged: (value) {
                    character.responseAlias = value;
                  },
                ),
                MaidTextField(
                  headingText: 'PrePrompt',
                  labelText: 'PrePrompt',
                  initialValue: character.prePrompt,
                  onChanged: (value) {
                    character.prePrompt = value;
                  },
                  multiline: true,
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                DoubleButtonRow(
                  leftText: "Add Example",
                  leftOnPressed: () {
                    setState(() {
                      character.examples.add({"prompt": "", "response": ""});
                    });
                  },
                  rightText: "Remove Example",
                  rightOnPressed: () {
                    setState(() {
                      character.examples.removeLast();
                    });
                  },
                ),
                const SizedBox(height: 10.0),
                ...List.generate(
                  character.examples.length,
                  (index) => Column(
                    children: [
                      MaidTextField(
                        headingText: 'Example prompt',
                        labelText: 'Prompt',
                        initialValue: character.examples[index]["prompt"],
                        onChanged: (value) {
                          character.examples[index]["prompt"] = value;
                        },
                      ),
                      MaidTextField(
                        headingText: 'Example response',
                        labelText: 'Response',
                        initialValue: character.examples[index]["response"],
                        onChanged: (value) {
                          character.examples[index]["response"] = value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (MessageManager.busy)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      )
    );
  }
}
