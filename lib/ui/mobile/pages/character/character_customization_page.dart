import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';
import 'package:maid_ui/maid_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterCustomizationPage extends StatefulWidget {
  const CharacterCustomizationPage({super.key});

  @override
  State<CharacterCustomizationPage> createState() =>
      _CharacterCustomizationPageState();
}

class _CharacterCustomizationPageState extends State<CharacterCustomizationPage> {
  bool regenerate = true;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController personalityController;
  late TextEditingController scenarioController;
  late TextEditingController systemController;
  late List<TextEditingController> greetingControllers;
  late List<TextEditingController> exampleControllers;

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final characterString = prefs.getString("last_character");

    if (characterString == null) {
      return;
    }

    final character = Character.fromMap(json.decode(characterString));

    final String charactersJson = prefs.getString("characters") ?? '[]';
    final List charactersList = json.decode(charactersJson);

    List<Character> characters;
    characters = charactersList.map((characterMap) {
      return Character.fromMap(characterMap);
    }).toList();

    characters.removeWhere((listCharacter) {
      return character.hash == listCharacter.hash;
    });
    characters.insert(0, character);

    final String newCharactersJson =
        json.encode(characters.map((character) => character.toMap()).toList());

    prefs.setString("characters", newCharactersJson);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    descriptionController.dispose();
    personalityController.dispose();
    scenarioController.dispose();
    systemController.dispose();
    
    for (var controller in greetingControllers) {
      controller.dispose();
    }
    for (var controller in exampleControllers) {
      controller.dispose();
    }

    save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "Character Customization"),
      body: Consumer<Character>(
        builder: (context, character, child) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString("last_character", json.encode(character.toMap()));
          });

          if (regenerate) {
            nameController = TextEditingController(text: character.name);
            descriptionController = TextEditingController(text: character.description);
            personalityController = TextEditingController(text: character.personality);
            scenarioController = TextEditingController(text: character.scenario);
            systemController = TextEditingController(text: character.system);

            greetingControllers = List.generate(
              character.greetings.length,
              (index) => TextEditingController(text: character.greetings[index]),
            );

            exampleControllers = List.generate(
              character.examples.length,
              (index) =>
                  TextEditingController(text: character.examples[index]["content"]),
            );

            save();

            regenerate = false;
          }

          return SessionBusyOverlay(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    FutureAvatar(
                      key: character.key,
                      image: character.profile,
                      radius: 75,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      character.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20.0),
                    GridView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200.0,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 15.0,
                        childAspectRatio: 6,
                        mainAxisExtent: 30
                      ),
                      children: [
                        FilledButton(
                          onPressed: () {
                            save();
                          },
                          child: Text(
                            "Save Changes",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            regenerate = true;
                            character.reset();
                          },
                          child: Text(
                            "Reset All",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            regenerate = true;
                            storageOperationDialog(context, character.importImage);
                          },
                          child: Text(
                            "Load Image",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            storageOperationDialog(context, character.exportImage);
                          },
                          child: Text(
                            "Save Image",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            storageOperationDialog(context, character.exportSTV2);
                          },
                          child: Text(
                            "Save STV2 JSON",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            storageOperationDialog(context, character.exportMCF);
                          },
                          child: Text(
                            "Save MCF JSON",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(
                              context,
                              '/characters'
                            );
                          },
                          child: Text(
                            "Switch Character",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            regenerate = true;
                            storageOperationDialog(context, character.importJSON);
                          },
                          child: Text(
                            "Load JSON",
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    TextFieldListTile(
                      headingText: 'Name',
                      labelText: 'Name',
                      controller: nameController,
                      onChanged: (value) {
                        character.name = value;
                      },
                      multiline: false,
                    ),
                    TextFieldListTile(
                      headingText: 'Description',
                      labelText: 'Description',
                      controller: descriptionController,
                      onChanged: (value) {
                        character.description = value;
                      },
                      multiline: true,
                    ),
                    TextFieldListTile(
                      headingText: 'Personality',
                      labelText: 'Personality',
                      controller: personalityController,
                      onChanged: (value) {
                        character.personality = value;
                      },
                      multiline: true,
                    ),
                    TextFieldListTile(
                      headingText: 'Scenario',
                      labelText: 'Scenario',
                      controller: scenarioController,
                      onChanged: (value) {
                        character.scenario = value;
                      },
                      multiline: true,
                    ),
                    TextFieldListTile(
                      headingText: 'System Prompt',
                      labelText: 'System Prompt',
                      controller: systemController,
                      onChanged: (value) {
                        character.system = value;
                      },
                      multiline: true,
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SwitchListTile(
                      title: const Text('Use Greeting'),
                      value: character.useGreeting,
                      onChanged: (value) {
                        character.useGreeting = value;
                      },
                    ),
                    if (character.useGreeting) ...[
                      ListTile(
                        leading: FilledButton(
                          onPressed: () {
                            regenerate = true;
                            character.newGreeting();
                          },
                          child: Text(
                            "Add Greeting",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        trailing: FilledButton(
                          onPressed: () {
                            regenerate = true;
                            character.removeLastGreeting();
                          },
                          child: Text(
                            "Remove Greeting",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      if (character.greetings.isNotEmpty) ...[
                        for (int i = 0; i < character.greetings.length; i++)
                          TextFieldListTile(
                            headingText: 'Greeting $i',
                            labelText: 'Greeting $i',
                            controller: greetingControllers[i],
                            onChanged: (value) {
                              character.updateGreeting(i, value);
                            },
                          ),
                      ],
                    ],
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SwitchListTile(
                      title: const Text('Use Examples'),
                      value: character.useExamples,
                      onChanged: (value) {
                        character.useExamples = value;
                      },
                    ),
                    if (character.useExamples) ...[
                      ListTile(
                        leading: FilledButton(
                          onPressed: () {
                            regenerate = true;
                            character.newExample(true);
                          },
                          child: Text(
                            "Add Prompt",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        trailing: FilledButton(
                          onPressed: () {
                            regenerate = true;
                            character.newExample(false);
                          },
                          child: Text(
                            "Add Response",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ListTile(
                        leading: FilledButton(
                          onPressed: () {
                            regenerate = true;
                            character.newExample(null);
                          },
                          child: Text(
                            "Add System",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        trailing: FilledButton(
                          onPressed: () {
                            if (exampleControllers.length >= 2) {
                              regenerate = true;
                              character.removeLastExample();
                            }
                          },
                          child: Text(
                            "Remove Last",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        )
                      ),
                      if (character.examples.isNotEmpty) ...[
                        for (int i = 0; i < character.examples.length; i++)
                          TextFieldListTile(
                            headingText:
                                '${Utilities.capitalizeFirst(character.examples[i]["role"])} Content',
                            labelText: character.examples[i]["role"],
                            controller: exampleControllers[i],
                            onChanged: (value) {
                              character.updateExample(i, value);
                            },
                          ),
                      ],
                    ]
                  ],
                ),
            )
          );
        },
      )
    );
  }
}
