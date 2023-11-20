import 'package:flutter/material.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/types/character.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';

class CharacterBody extends StatefulWidget {
  const CharacterBody({super.key});

  @override
  State<CharacterBody> createState() => _CharacterBodyState();
}

class _CharacterBodyState extends State<CharacterBody> {
  @override
  void dispose() {
    MemoryManager.saveCharacters();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              CircleAvatar(
                backgroundImage: const AssetImage("assets/default_profile.png"),
                foregroundImage: Image.file(character.profile).image,
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
                    (String characterName) {
                      return character.name == characterName;
                    },
                    () => setState(() {}),
                    () async {
                      MemoryManager.saveCharacters();
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
                leftText: "Load Image",
                leftOnPressed: () async {
                  await storageOperationDialog(context, character.importImage);
                  setState(() {});
                },
                rightText: "Save Image",
                rightOnPressed: () async {
                  await storageOperationDialog(context, character.exportImage);
                  setState(() {});
                },
              ),
              const SizedBox(height: 15.0),
              DoubleButtonRow(
                leftText: "Load JSON",
                leftOnPressed: () async {
                  await storageOperationDialog(context, character.importJSON);
                  setState(() {});
                },
                rightText: "Save JSON",
                rightOnPressed: () async {
                  await storageOperationDialog(context, character.exportJSON);
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
    );
  }
}