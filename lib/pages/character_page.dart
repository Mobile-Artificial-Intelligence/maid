import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/double_button_row.dart';
import 'package:maid/widgets/text_field_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  static Map<String, dynamic> _characters = {};
  late Character cachedCharacter;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _personalityController;
  late TextEditingController _scenarioController;
  late TextEditingController _greetingController;
  late TextEditingController _systemController;
  late List<TextEditingController> _exampleControllers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      _characters = json.decode(prefs.getString("characters") ?? "{}");
      setState(() {});
    });

    final character = context.read<Character>();
    _nameController = TextEditingController(text: character.name);
    _descriptionController = TextEditingController(text: character.description);
    _personalityController = TextEditingController(text: character.personality);
    _scenarioController = TextEditingController(text: character.scenario);
    _greetingController = TextEditingController(text: character.greeting);
    _systemController = TextEditingController(text: character.system);

    _exampleControllers = List.generate(
      character.examples.length,
      (index) =>
          TextEditingController(text: character.examples[index]["content"]),
    );
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      _characters[cachedCharacter.name] = cachedCharacter.toMap();
      Logger.log("Character Saved: ${cachedCharacter.name}");
      prefs.setString("characters", json.encode(_characters));
    });

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
          title: const Text("Character"),
        ),
        body: Consumer<Character>(
          builder: (context, character, child) {
            cachedCharacter = character;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      CircleAvatar(
                        backgroundImage:
                            const AssetImage("assets/default_profile.png"),
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
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Consumer<Character>(
                                    builder: (context, character, child) {
                                      return AlertDialog(
                                        title: const Text(
                                          "Switch Character",
                                          textAlign: TextAlign.center,
                                        ),
                                        content: SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: ListView.builder(
                                            itemCount: _characters.keys.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final item = _characters.keys
                                                  .elementAt(index);

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Dismissible(
                                                  key: ValueKey(item),
                                                  background: Container(
                                                      color: Colors.red),
                                                  onDismissed: (direction) {
                                                    setState(() {
                                                      _characters.remove(item);
                                                      if (character.name ==
                                                          item) {
                                                        character.fromMap(
                                                            _characters.values
                                                                    .lastOrNull ??
                                                                {});
                                                      }
                                                    });
                                                    Logger.log(
                                                        "Character Removed: $item");
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: character.name ==
                                                              item
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .tertiary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  15.0)),
                                                    ),
                                                    child: ListTile(
                                                      title: Text(
                                                        item,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      onTap: () {
                                                        character.fromMap(
                                                            _characters[item]);
                                                        Logger.log(
                                                            "Character Set: ${character.name}");
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0)),
                                        ),
                                        actions: [
                                          FilledButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Close",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              _characters[character.name] =
                                                  character.toMap();
                                              character.newCharacter();
                                              _characters[character.name] =
                                                  character.toMap();
                                              character.notify();
                                            },
                                            child: Text(
                                              "New Preset",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                          },
                          rightText: "Reset All",
                          rightOnPressed: () {
                            character.resetAll();
                          }),
                      const SizedBox(height: 15.0),
                      DoubleButtonRow(
                        leftText: "Load Image",
                        leftOnPressed: () async {
                          await storageOperationDialog(
                              context, character.importImage);
                        },
                        rightText: "Save Image",
                        rightOnPressed: () async {
                          await storageOperationDialog(
                              context, character.exportImage);
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 15.0),
                      DoubleButtonRow(
                        leftText: "Load JSON",
                        leftOnPressed: () async {
                          await storageOperationDialog(
                              context, character.importJSON);
                        },
                        rightText: "Save JSON",
                        rightOnPressed: () async {
                          await storageOperationDialog(
                              context, character.exportJSON);
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
                                cursorColor:
                                    Theme.of(context).colorScheme.secondary,
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                ),
                                controller: _nameController,
                                onChanged: (value) {
                                  if (_characters.keys.contains(value)) {
                                    character.fromMap(_characters[value] ?? {});
                                    Logger.log(
                                        "Character Set: ${character.name}");
                                  } else if (value.isNotEmpty) {
                                    String oldName = character.name;
                                    Logger.log(
                                        "Updating character $oldName ====> $value");
                                    character.setName(value);
                                    _characters.remove(oldName);
                                  }
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
                          character.setDescription(value);
                        },
                        multiline: true,
                      ),
                      TextFieldListTile(
                        headingText: 'Personality',
                        labelText: 'Personality',
                        controller: _personalityController,
                        onChanged: (value) {
                          character.setPersonality(value);
                        },
                        multiline: true,
                      ),
                      TextFieldListTile(
                        headingText: 'Scenario',
                        labelText: 'Scenario',
                        controller: _scenarioController,
                        onChanged: (value) {
                          character.setScenario(value);
                        },
                        multiline: true,
                      ),
                      SwitchListTile(
                        title: const Text('Use Greeting'),
                        value: character.useGreeting,
                        onChanged: (value) {
                          character.setUseGreeting(value);
                        },
                      ),
                      if (character.useGreeting) ...[
                        TextFieldListTile(
                          headingText: 'Greeting',
                          labelText: 'Greeting',
                          controller: _greetingController,
                          onChanged: (value) {
                            character.setGreeting(value);
                          },
                          multiline: true,
                        ),
                      ],
                      TextFieldListTile(
                        headingText: 'System Prompt',
                        labelText: 'System Prompt',
                        controller: _systemController,
                        onChanged: (value) {
                          character.setSystem(value);
                        },
                        multiline: true,
                      ),
                      Divider(
                        indent: 10,
                        endIndent: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: const Text('Use Examples'),
                        value: character.useExamples,
                        onChanged: (value) {
                          character.setUseExamples(value);
                        },
                      ),
                      if (character.useExamples) ...[
                        DoubleButtonRow(
                          leftText: "Add Example",
                          leftOnPressed: () {
                            _exampleControllers.addAll([
                              TextEditingController(),
                              TextEditingController()
                            ]);
                            character.newExample();
                          },
                          rightText: "Remove Example",
                          rightOnPressed: () {
                            _exampleControllers.removeRange(
                                _exampleControllers.length - 2,
                                _exampleControllers.length);
                            character.removeLastExample();
                          },
                        ),
                        const SizedBox(height: 10.0),
                        ...List.generate(
                          character.examples.length,
                          (index) => TextFieldListTile(
                            headingText:
                                '${character.examples[index]["role"]} content',
                            labelText: character.examples[index]["role"],
                            controller: _exampleControllers[index],
                            onChanged: (value) {
                              character.updateExample(index, value);
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                if (context.watch<Session>().isBusy)
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
          },
        ));
  }
}
