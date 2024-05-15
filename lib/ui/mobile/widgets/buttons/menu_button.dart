import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:maid/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart'
if (dart.library.html) 'package:maid/mocks/mock_llama_cpp_page.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({super.key});

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  final iconButtonKey = GlobalKey();
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
    return Consumer<Session>(
      builder: (context, session, child) {
        if (canUseCache(session)) {
          options = cache;
          return IconButton(
            key: iconButtonKey,
            icon: const Icon(
              Icons.account_tree_rounded,
              size: 24,
            ),
            onPressed: onPressed,
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

                return IconButton(
                  key: iconButtonKey,
                  icon: const Icon(
                    Icons.account_tree_rounded,
                    size: 24,
                  ),
                  onPressed: onPressed,
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

  void onPressed() {
    final RenderBox renderBox = iconButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    List<PopupMenuEntry<dynamic>> modelOptions = options.map((String modelName) => PopupMenuItem(
      padding: EdgeInsets.zero,
      child: Consumer<Session>(
        builder: 
          (context, session, child) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              title: Text(modelName),
              onTap: () {
                session.model.name = modelName;
              },
              tileColor: session.model.name == modelName ? Theme.of(context).colorScheme.secondary : null,
            );
          }
    )))
    .toList();
    
    showMenu(
      context: context,
      // Calculate the position based on the button's position and size
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx,
        offset.dy,
      ),
      items: [
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  switch (context.read<Session>().model.type) {
                    case LargeLanguageModelType.llamacpp:
                      return const LlamaCppPage();
                    case LargeLanguageModelType.ollama:
                      return const OllamaPage();
                    case LargeLanguageModelType.openAI:
                      return const OpenAiPage();
                    case LargeLanguageModelType.mistralAI:
                      return const MistralAiPage();
                    case LargeLanguageModelType.gemini:
                      return const GoogleGeminiPage();
                    default:
                      return const LlamaCppPage();
                  }
                }),
              );
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
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the menu first
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ),
      ],
    );
  }
}