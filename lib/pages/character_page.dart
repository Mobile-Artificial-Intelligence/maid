import 'package:flutter/material.dart';
import 'package:maid/widgets/settings_widgets.dart';
import 'package:maid/config/settings.dart';
import 'package:maid/config/character.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  TextEditingController presetController = TextEditingController();
  
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    settings.save();
    presetController.dispose();
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
                DropdownMenu<String>(
                  width: 250.0,
                  initialSelection: character.name,
                  controller: presetController,
                  dropdownMenuEntries: settings.getCharacters().map<DropdownMenuEntry<String>>(
                    (String value) {
                      return DropdownMenuEntry<String>(
                        value: value,
                        label: value,
                      );
                    },
                  ).toList(),
                  onSelected: (value) => setState(() async {
                    if (value == null) {
                      await settings.updateCharacter(presetController.text);
                    } else {
                      await settings.setCharacter(value);
                    }
                    setState(() {});
                  }),
                ),
                const SizedBox(height: 15.0),
                doubleButtonRow(
                  context,
                  "New Preset",
                  () async {
                    await settings.save();
                    character = Character();
                    character.name = "New Preset";
                    setState(() {});
                  },
                  "Delete Preset",
                  () async {
                    await settings.removeCharacter();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20.0),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                doubleButtonRow(
                  context,
                  "Load Character",
                  () async {
                    await storageOperationDialog(context, character.loadCharacterFromJson);
                    setState(() {});
                  },
                  "Save Character",
                  () async {
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
                settingsTextField(
                  'User alias', character.userAliasController),
                settingsTextField(
                  'Response alias', character.responseAliasController),
                ListTile(
                  title: Row(
                    children: [
                      const Expanded(
                        child: Text('PrePrompt'),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: character.prePromptController,
                          decoration: const InputDecoration(
                            labelText: 'PrePrompt',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                doubleButtonRow(
                  context,
                  "Add Example",
                  () {
                    setState(() {
                      character.examplePromptControllers.add(TextEditingController());
                      character.exampleResponseControllers.add(TextEditingController());
                    });
                  },
                  "Remove Example",
                  () {
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
                      settingsTextField('Example prompt', character.examplePromptControllers[index]),
                      settingsTextField('Example response', character.exampleResponseControllers[index]),
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
