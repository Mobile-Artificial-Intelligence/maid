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
        builder: buildBody,
      )
    );
  }

  Widget buildBody(BuildContext context, Character character, Widget? child) {
    character.save();

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

    return customColumn([
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
      buttonGridView(character),
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
      Divider(
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
      SwitchListTile(
        title: const Text('Use System'),
        value: character.useSystem,
        onChanged: (value) {
          character.useSystem = value;
        },
      ),
      if (character.useSystem) ...system(character),
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
      if (character.useGreeting) ...greetings(character),
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
      if (character.useExamples) ...examples(character),
    ]);
  }

  Widget customColumn(List<Widget> children) {
    return SessionBusyOverlay(
      child: SingleChildScrollView(
        child: Column(
          children: children
        )
      )
    );
  }

  Widget buttonGridView(Character character) {
    return GridView(
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
          child: const Text(
            "Save Changes",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            character.reset();
          },
          child: const Text(
            "Reset All",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            storageOperationDialog(context, character.importImage);
          },
          child: const Text(
            "Load Image",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            storageOperationDialog(context, character.exportImage);
          },
          child: const Text(
            "Save Image",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            storageOperationDialog(context, character.exportSTV2);
          },
          child: const Text(
            "Save STV2 JSON",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            storageOperationDialog(context, character.exportMCF);
          },
          child: const Text(
            "Save MCF JSON",
            softWrap: false
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
          child: const Text(
            "Switch Character",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            storageOperationDialog(context, character.importJSON);
          },
          child: const Text(
            "Load JSON",
            softWrap: false
          ),
        ),
      ],
    );
  }

  List<Widget> greetings(Character character) {
    List<Widget> widgets = [
      ListTile(
        leading: FilledButton(
          onPressed: () {
            regenerate = true;
            character.newGreeting();
          },
          child: const Text(
            "Add Greeting"
          ),
        ),
        trailing: FilledButton(
          onPressed: () {
            regenerate = true;
            character.removeLastGreeting();
          },
          child: const Text(
            "Remove Greeting"
          ),
        ),
      ),
      const SizedBox(height: 10.0),
    ];

    if (character.greetings.isNotEmpty) {
      for (int i = 0; i < character.greetings.length; i++) {
        widgets.add(
          TextFieldListTile(
            headingText: 'Greeting $i',
            labelText: 'Greeting $i',
            controller: greetingControllers[i],
            onChanged: (value) {
              character.updateGreeting(i, value);
            },
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> examples(Character character) {
    List<Widget> widgets = [
      ListTile(
        leading: FilledButton(
          onPressed: () {
            regenerate = true;
            character.newExample(true);
          },
          child: const Text(
            "Add Prompt"
          ),
        ),
        trailing: FilledButton(
          onPressed: () {
            regenerate = true;
            character.newExample(false);
          },
          child: const Text(
            "Add Response"
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
          child: const Text(
            "Add System"
          ),
        ),
        trailing: FilledButton(
          onPressed: () {
            if (exampleControllers.length >= 2) {
              regenerate = true;
              character.removeLastExample();
            }
          },
          child: const Text(
            "Remove Last"
          ),
        )
      ),
    ];

    if (character.examples.isNotEmpty) {
      for (int i = 0; i < character.examples.length; i++) {
        widgets.add(
          TextFieldListTile(
            headingText:'${Utilities.capitalizeFirst(character.examples[i]["role"])} Content',
            labelText: character.examples[i]["role"],
            controller: exampleControllers[i],
            onChanged: (value) {
              character.updateExample(i, value);
            },
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> system(Character character) {
    return [
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
    ];
  }
}
