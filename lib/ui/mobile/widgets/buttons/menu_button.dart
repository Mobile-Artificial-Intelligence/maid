import 'package:flutter/material.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({super.key});

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  static LargeLanguageModelType lastModelType = LargeLanguageModelType.none;
  static DateTime lastCheck = DateTime.now();
  static List<String> cache = [];
  List<String> options = [];

  bool canUseCache(Session session) {
    if (cache.isEmpty && session.model.type != LargeLanguageModelType.llamacpp) return false;

    if (session.model.type != lastModelType) return false;

    if (DateTime.now().difference(lastCheck).inMinutes > 1) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        if (canUseCache(session)) {
          options = cache;
          return PopupMenuButton(
            tooltip: 'Open Menu',
            icon: const Icon(
              Icons.account_tree_rounded,
              size: 24,
            ),
            itemBuilder: itemBuilder
          );
        } 
        else {
          lastModelType = session.model.type;
          lastCheck = DateTime.now();
          return FutureBuilder(
            future: session.model.options,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                options = snapshot.data as List<String>;
                cache = options;
                return PopupMenuButton(
                  tooltip: 'Open Menu',
                  icon: const Icon(
                    Icons.account_tree_rounded,
                    size: 24,
                  ),
                  itemBuilder: itemBuilder
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8.0),  // Adjust padding to match the visual space of the IconButton
                  child: SizedBox(
                    width: 24,  // Width of the CircularProgressIndicator
                    height: 24,  // Height of the CircularProgressIndicator
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,  // Adjust the thickness of the spinner here
                      ),
                    ),
                  ),
                );
              }
            }
          );
        }
      }
    );
  }

  List<PopupMenuEntry<dynamic>> itemBuilder(BuildContext context) {
    List<PopupMenuEntry<dynamic>> modelOptions = options.map((String modelName) => PopupMenuItem(
      padding: EdgeInsets.zero,
      child: Consumer<AppData>(
          builder: (context, appData, child) {
            final model = appData.currentSession.model;
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              title: Text(modelName),
              onTap: () {
                model.name = modelName;
              },
              tileColor: model.name == modelName ? Theme.of(context).colorScheme.secondary : null,
            );
          }
        )
      )
    ).toList();

    return [
      ...modelOptions,
      if (modelOptions.isNotEmpty)
        const PopupMenuDivider(
          height: 10,
        ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Model Settings'),
          onTap: () {
            switch (Session.of(context).model.type) {
              case LargeLanguageModelType.llamacpp:
                Navigator.pushNamed(context, '/llamacpp');
              case LargeLanguageModelType.ollama:
                Navigator.pushNamed(context, '/ollama');
              case LargeLanguageModelType.openAI:
                Navigator.pushNamed(context, '/openai');
              case LargeLanguageModelType.mistralAI:
                Navigator.pushNamed(context, '/mistralai');
              case LargeLanguageModelType.gemini:
                Navigator.pushNamed(context, '/gemini');
              default:
                throw Exception('Invalid model type');
            }
          },
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('App Settings'),
          onTap: () {
            cache.clear();
            Navigator.pushNamed(
              context,
              '/settings'
            );
          },
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('About'),
          onTap: () {
            Navigator.pushNamed(context, '/about');
          },
        ),
      )
    ];
  }
}