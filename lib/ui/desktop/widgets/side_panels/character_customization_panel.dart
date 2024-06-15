import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/shared/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/shared/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';
import 'package:maid/ui/shared/widgets/future_avatar.dart';
import 'package:provider/provider.dart';

class CharacterCustomizationPanel extends StatefulWidget {
  const CharacterCustomizationPanel({super.key});

  @override
  State<CharacterCustomizationPanel> createState() =>
      _CharacterCustomizationPanelState();
}

class _CharacterCustomizationPanelState extends State<CharacterCustomizationPanel> {
  bool regenerate = true;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController personalityController;
  late TextEditingController scenarioController;
  late TextEditingController systemController;
  late List<TextEditingController> greetingControllers;
  late List<TextEditingController> exampleControllers;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "Character Customization"),
      body: Consumer<AppData>(
        builder: buildBody,
      )
    );
  }

  Widget buildBody(BuildContext context, AppData appData, Widget? child) {
    final character = appData.currentCharacter;

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
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
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
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          FilledButton(
            onPressed: () {
              regenerate = true;
              character.newGreeting();
            },
            child: const Text(
              "Add Greeting"
            ),
          ),
          FilledButton(
            onPressed: () {
              regenerate = true;
              character.removeLastGreeting();
            },
            child: const Text(
              "Remove Greeting"
            ),
          )
        ]
      ),
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
      examplesButtonsWrap()
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

  Widget examplesButtonsWrap() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        FilledButton(
          onPressed: () {
            regenerate = true;
            Character.of(context).newExample(true);
          },
          child: const Text(
            "Add Prompt",
            overflow: TextOverflow.ellipsis
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            Character.of(context).newExample(false);
          },
          child: const Text(
            "Add Response",
            overflow: TextOverflow.ellipsis
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            Character.of(context).newExample(null);
          },
          child: const Text(
            "Add System",
            overflow: TextOverflow.ellipsis
          ),
        ),
        FilledButton(
          onPressed: () {
            if (exampleControllers.length >= 2) {
              regenerate = true;
              Character.of(context).removeLastExample();
            }
          },
          child: const Text(
            "Remove Last",
            overflow: TextOverflow.ellipsis
          ),
        )
      ]
    );
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
