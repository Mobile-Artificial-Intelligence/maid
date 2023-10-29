import 'package:flutter/material.dart';
import 'package:maid/config/character.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  void _storageOperationDialog(Future<String> Function() storageFunction) async {
    String ret = await storageFunction();
    // Use a local reference to context to avoid using it across an async gap.
    final localContext = context;
    // Ensure that the context is still valid before attempting to show the dialog.
    if (localContext.mounted) {
      showDialog(
        context: localContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(ret),
            alignment: Alignment.center,
            actionsAlignment: MainAxisAlignment.center,
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            actions: [
              FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
            ],
          );
        },
      );
      character.saveSharedPreferences();
      setState(() {});
    }
  }

  @override
  initState() {
    super.initState();
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
                  character.jsonCharacter["responseAlias"],
                  style: Theme.of(context).textTheme.titleSmall
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        _storageOperationDialog(character.loadCharacterFromJson);
                      },
                      child: Text(
                        "Load Character",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        _storageOperationDialog(character.saveCharacterToJson);
                      },
                      child: Text(
                        "Save Character",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                  ],
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
                llamaParamTextField(
                  'User alias', character.userAliasController),
                llamaParamTextField(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          character.examplePromptControllers.add(TextEditingController());
                          character.exampleResponseControllers.add(TextEditingController());
                        });
                      },
                      child: Text(
                        "Add Example",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          character.examplePromptControllers.removeLast();
                          character.exampleResponseControllers.removeLast();
                        });
                      },
                      child: Text(
                        "Remove Example",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                ...List.generate(
                  (character.examplePromptControllers.length == character.exampleResponseControllers.length) ? character.examplePromptControllers.length : 0,
                  (index) => Column(
                    children: [
                      llamaParamTextField('Example prompt', character.examplePromptControllers[index]),
                      llamaParamTextField('Example response', character.exampleResponseControllers[index]),
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

  Widget llamaParamTextField(String labelText, TextEditingController controller) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(labelText),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
              )
            ),
          ),
        ],
      ),
    );
  }
}
