import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterBody extends StatefulWidget {
  const CharacterBody({super.key});

  @override
  State<CharacterBody> createState() => _CharacterBodyState();
}

class _CharacterBodyState extends State<CharacterBody> {
  static Map<String, dynamic> _characters = {};
  late Character cachedCharacter;

  late TextEditingController _nameController;
  late TextEditingController _userAliasController;
  late TextEditingController _responseAliasController;
  late TextEditingController _prePromptController;
  late List<TextEditingController> _exampleControllers;

  void updateControllers() {
    final character = context.read<Character>();

    setState(() {
      _nameController.text = character.name;
      _userAliasController.text = character.userAlias;
      _responseAliasController.text = character.responseAlias;
      _prePromptController.text = character.prePrompt;

      for (int i = 0; i < character.examples.length; i++) {
        _exampleControllers[i].text = character.examples[i]["content"];
      }
    });
  }
  
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
    _userAliasController = TextEditingController(text: character.userAlias);
    _responseAliasController = TextEditingController(text: character.responseAlias);
    _prePromptController = TextEditingController(text: character.prePrompt);

    _exampleControllers = List.generate(
      character.examples.length,
      (index) => TextEditingController(text: character.examples[index]["content"]),
    );
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      _characters[cachedCharacter.name] = cachedCharacter.toMap();
      Logger.log("Character Saved: ${cachedCharacter.name}");

      prefs.setString("characters", json.encode(_characters));
      prefs.setString("last_character", json.encode(cachedCharacter.toMap()));
    });

    GenerationManager.cleanup();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<Character>(
      builder: (context, character, child) {       
        cachedCharacter = character;
        
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
                        () {
                          return _characters.keys.toList();
                        }, 
                        (String characterName) {
                          character.fromMap(_characters[characterName] ?? {});
                          Logger.log("Character Set: ${character.name}");
                        },
                        (String characterName) {
                          _characters.remove(characterName);
                          String? key = _characters.keys.lastOrNull;

                          if (key == null) {
                            character.resetAll();
                          } else {
                            character.fromMap(_characters[key]!);
                          }
                        },
                        (String characterName) {
                          return character.name == characterName;
                        },
                        () => setState(() {}),
                        () async {
                          final prefs = await SharedPreferences.getInstance();
                          _characters[character.name] = character.toMap();
                          Logger.log("Character Saved: ${character.name}");

                          prefs.setString("characters", json.encode(_characters));
                          prefs.setString("last_character", character.name);
                          GenerationManager.cleanup();

                          character.resetAll();
                          character.setName("New Character");
                        }
                      );
                    }, 
                    rightText: "Reset All", 
                    rightOnPressed: () {
                      character.resetAll();
                      updateControllers();
                    }
                  ),
                  const SizedBox(height: 15.0),
                  DoubleButtonRow(
                    leftText: "Load Image",
                    leftOnPressed: () async {
                      await storageOperationDialog(context, character.importImage);
                      updateControllers();
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
                      updateControllers();
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
                            controller: _nameController,
                            onChanged: (value) {
                              if (_characters.keys.contains(value)) {
                                character.fromMap(_characters[value] ?? {});
                                Logger.log("Character Set: ${character.name}");
                              } else if (value.isNotEmpty) {
                                String oldName = character.name;
                                Logger.log("Updating character $oldName ====> $value");
                                character.setName(value);
                                _characters.remove(oldName);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaidTextField(
                    headingText: 'User alias', 
                    labelText: 'Alias',
                    controller: _userAliasController,
                    onChanged: (value) {
                      character.setUserAlias(value);
                    },
                  ),
                  MaidTextField(
                    headingText: 'Response alias',
                    labelText: 'Alias',
                    controller: _responseAliasController,
                    onChanged: (value) {
                      character.setResponseAlias(value);
                    },
                  ),
                  MaidTextField(
                    headingText: 'PrePrompt',
                    labelText: 'PrePrompt',
                    controller: _prePromptController,
                    onChanged: (value) {
                      character.setPrePrompt(value);
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
                      character.newExample();
                    },
                    rightText: "Remove Example",
                    rightOnPressed: () {
                      character.removeLastExample();
                    },
                  ),
                  const SizedBox(height: 10.0),
                  ...List.generate(
                    character.examples.length,
                    (index) => MaidTextField(
                      headingText: '${character.examples[index]["role"]} content',
                      labelText: character.examples[index]["role"],
                      controller: _exampleControllers[index],
                      onChanged: (value) {
                        character.updateExample(index, value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (GenerationManager.busy)
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
    );
  }
}