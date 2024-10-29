import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/ui/shared/widgets/settings_drawer.dart';
import 'package:your_app/ui/shared/screens/chat_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modelProvider = context.watch<ModelProvider>();
    final characterProvider = context.watch<CharacterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(characterProvider.selectedCharacter?.name ?? 'Maid'),
        actions: [
          // Model indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(modelProvider.currentModel?.name ?? 'No Model'),
              avatar: const Icon(Icons.memory),
            ),
          ),
        ],
      ),
      body: const ChatView(),
      drawer: SettingsDrawer(),
    );
  }
}
