import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modelProvider = context.watch<ModelProvider>();
    final characterProvider = context.watch<CharacterProvider>();

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Model: ${modelProvider.currentModel?.name ?? 'None'}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Character: ${characterProvider.selectedCharacter?.name ?? 'None'}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('Model Settings'),
            subtitle: Text(
              'Temperature: ${modelProvider.temperature.toStringAsFixed(2)}\n'
              'Max Tokens: ${modelProvider.maxTokens}',
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModelSelectionScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Character Settings'),
            subtitle: Text(characterProvider.selectedCharacter?.name ?? 'None'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CharacterSelectionScreen(),
                ),
              );
            },
          ),
          // Add reset settings option
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset Settings'),
            onTap: () => _showResetDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default values?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final settings = AppSettingsService();
      await settings.clearAllSettings();
      
      // Reset providers
      context.read<ModelProvider>().reset();
      context.read<CharacterProvider>().reset();
      
      if (context.mounted) {
        Navigator.pop(context); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults')),
        );
      }
    }
  }
}
