import 'package:flutter/material.dart';
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
                Text(
                  character.nameController.text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20.0),
                FilledButton(
                  onPressed: () {
                    switcherDialog(
                      context, 
                      MemoryManager.getModels, 
                      MemoryManager.setModel, 
                      () => setState(() {}),
                      () async {
                        MemoryManager.save();
                        character = Character();
                        character.nameController.text = "New Character";
                        setState(() {});
                      }
                    );
                  },
                  child: Text(
                    "Switch Character",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 15.0),
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
                          controller: character.nameController,
                          decoration: const InputDecoration(
                            labelText: "Name",
                          ),
                          onSubmitted: (value) {
                            if (MemoryManager.getCharacters().contains(value)) {
                              MemoryManager.setCharacter(value);
                            } else if (value.isNotEmpty) {
                              MemoryManager.updateCharacter(character.nameController.text);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                DoubleButtonRow(
                  leftText: "New Preset",
                  leftOnPressed: () async {
                    MemoryManager.save();
                    character = Character();
                    character.nameController.text = "New Preset";
                    setState(() {});
                  },
                  rightText: "Delete Preset",
                  rightOnPressed: () async {
                    MemoryManager.removeCharacter();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20.0),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                DoubleButtonRow(
                  leftText: "Load Character",
                  leftOnPressed: () async {
                    await storageOperationDialog(context, character.loadCharacterFromJson);
                    setState(() {});
                  },
                  rightText: "Save Character",
                  rightOnPressed: () async {
                    await storageOperationDialog(context, character.saveCharacterToJson);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10.0),
                FilledButton(
                  onPressed: () {
                    character.resetAll();
                    setState(() {});
                  },
                  child: Text(
                    "Reset All",
                    style: Theme.of(context).textTheme.labelLarge
                  ),
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                MaidTextField(
                  labelText: 'User alias', 
                  controller: character.userAliasController
                ),
                MaidTextField(
                  labelText: 'Response alias', 
                  controller: character.responseAliasController
                ),
                MaidTextField(
                  labelText: 'PrePrompt',
                  controller: character.prePromptController,
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
                      character.examplePromptControllers.add(TextEditingController());
                      character.exampleResponseControllers.add(TextEditingController());
                    });
                  },
                  rightText: "Remove Example",
                  rightOnPressed: () {
                    setState(() {
                      character.examplePromptControllers.removeLast();
                      character.exampleResponseControllers.removeLast();
                    });
                  },
                ),
                const SizedBox(height: 10.0),
                ...List.generate(
                  (character.examplePromptControllers.length == character.exampleResponseControllers.length) ? character.examplePromptControllers.length : 0,
                  (index) => Column(
                    children: [
                      MaidTextField(
                        labelText: 'Example prompt', 
                        controller: character.examplePromptControllers[index]
                      ),
                      MaidTextField(
                        labelText: 'Example response', 
                        controller: character.exampleResponseControllers[index]
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (character.busy)
            // This is a semi-transparent overlay that will cover the entire screen.
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
