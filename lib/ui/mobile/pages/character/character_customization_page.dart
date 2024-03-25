import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/pages/character/character_browser_page.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterCustomizationPage extends StatefulWidget {
  const CharacterCustomizationPage({super.key});

  @override
  State<CharacterCustomizationPage> createState() =>
      _CharacterCustomizationPageState();
}

class _CharacterCustomizationPageState extends State<CharacterCustomizationPage> {
  bool _regenerate = true;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _personalityController;
  late TextEditingController _scenarioController;
  late TextEditingController _systemController;
  late List<TextEditingController> _greetingControllers;
  late List<TextEditingController> _exampleControllers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "Character Customization"),
      body: Consumer<Character>(
        builder: (context, character, child) {
          if (_regenerate) {
            _nameController = TextEditingController(text: character.name);
            _descriptionController = TextEditingController(text: character.description);
            _personalityController = TextEditingController(text: character.personality);
            _scenarioController = TextEditingController(text: character.scenario);
            _systemController = TextEditingController(text: character.system);

            _greetingControllers = List.generate(
              character.greetings.length,
              (index) => TextEditingController(text: character.greetings[index]),
            );

            _exampleControllers = List.generate(
              character.examples.length,
              (index) =>
                  TextEditingController(text: character.examples[index]["content"]),
            );

            _regenerate = false;
          }

          SharedPreferences.getInstance().then((prefs) {
            prefs.setString("last_character", json.encode(character.toMap()));
          });

          return SessionBusyOverlay(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    CircleAvatar(
                      backgroundImage: const AssetImage("assets/maid.png"),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CharacterBrowserPage()));
                          },
                          child: Text(
                            "Switch Character",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        FilledButton(
                          onPressed: () {
                            _regenerate = true;
                            character.reset();
                          },
                          child: Text(
                            "Reset All",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () async {
                            _regenerate = true;
                            await storageOperationDialog(context, character.importImage);
                          },
                          child: Text(
                            "Load Image",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        FilledButton(
                          onPressed: () async {
                            await storageOperationDialog(context, character.exportImage);
                          },
                          child: Text(
                            "Save Image",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () async {
                            await storageOperationDialog(context, character.exportSTV2);
                          },
                          child: Text(
                            "Save STV2 JSON",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        FilledButton(
                          onPressed: () async {
                            await storageOperationDialog(context, character.exportMCF);
                          },
                          child: Text(
                            "Save MCF JSON",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    FilledButton(
                      onPressed: () async {
                        _regenerate = true;
                        await storageOperationDialog(context, character.importJSON);
                      },
                      child: Text(
                        "Load JSON",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
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
                            child: Text("Name"),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              decoration: const InputDecoration(
                                labelText: "Name",
                              ),
                              controller: _nameController,
                              onChanged: (value) {
                                character.name = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFieldListTile(
                      headingText: 'Description',
                      labelText: 'Description',
                      controller: _descriptionController,
                      onChanged: (value) {
                        character.description = value;
                      },
                      multiline: true,
                    ),
                    TextFieldListTile(
                      headingText: 'Personality',
                      labelText: 'Personality',
                      controller: _personalityController,
                      onChanged: (value) {
                        character.personality = value;
                      },
                      multiline: true,
                    ),
                    TextFieldListTile(
                      headingText: 'Scenario',
                      labelText: 'Scenario',
                      controller: _scenarioController,
                      onChanged: (value) {
                        character.scenario = value;
                      },
                      multiline: true,
                    ),
                    TextFieldListTile(
                      headingText: 'System Prompt',
                      labelText: 'System Prompt',
                      controller: _systemController,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: character.newGreeting,
                            child: Text(
                              "Add Greeting",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          FilledButton(
                            onPressed: character.removeLastGreeting,
                            child: Text(
                              "Remove Greeting",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      if (character.greetings.isNotEmpty) ...[
                        for (int i = 0; i < character.greetings.length; i++)
                          TextFieldListTile(
                            headingText: 'Greeting $i',
                            labelText: 'Greeting $i',
                            controller: _greetingControllers[i],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: () {
                              _regenerate = true;
                              character.newExample(true);
                            },
                            child: Text(
                              "Add Prompt",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          FilledButton(
                            onPressed: () {
                              _regenerate = true;
                              character.newExample(false);
                            },
                            child: Text(
                              "Add Response",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: () {
                              _regenerate = true;
                              character.newExample(null);
                            },
                            child: Text(
                              "Add System",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          FilledButton(
                            onPressed: () {
                              if (_exampleControllers.length >= 2) {
                                _regenerate = true;
                                character.removeLastExample();
                              }
                            },
                            child: Text(
                              "Remove Last",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                      if (character.examples.isNotEmpty) ...[
                        for (int i = 0; i < character.examples.length; i++)
                          TextFieldListTile(
                            headingText:
                                '${character.examples[i]["role"]} content',
                            labelText: character.examples[i]["role"],
                            controller: _exampleControllers[i],
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
