import 'package:babylon_tts/babylon_tts.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:maid/classes/providers/sessions.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/ui/desktop/app.dart';
import 'package:maid/ui/mobile/app.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Babylon.init();

  AppPreferences appPreferences = await AppPreferences.last;
  Sessions sessions = await Sessions.last;
  CharacterCollection characters = await CharacterCollection.last;
  ArtificialIntelligence ai = await ArtificialIntelligence.last;
  User user = await User.last;

  runApp(
    MaidApp(
      appPreferences: appPreferences, 
      sessions: sessions,
      characters: characters,
      ai: ai,
      user: user
    )
  );
}

class MaidApp extends StatelessWidget {
  final AppPreferences appPreferences;
  final Sessions sessions;
  final CharacterCollection characters;
  final ArtificialIntelligence ai;
  final User user;

  const MaidApp({
    super.key, 
    required this.appPreferences, 
    required this.sessions,
    required this.characters,
    required this.ai, 
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appPreferences),
        ChangeNotifierProvider(create: (context) => sessions),
        ChangeNotifierProvider(create: (context) => characters),
        ChangeNotifierProvider(create: (context) => ai),
        ChangeNotifierProvider(create: (context) => user),
        ChangeNotifierProvider(create: (context) => HuggingfaceSelection())
      ],
      child: Selector<AppPreferences, bool>(
        selector: (context, appPreferences) => appPreferences.isDesktop,
        builder: (context, isDesktop, child) {
          if (isDesktop) {
            return const DesktopApp();
          } 
          else {
            return const MobileApp();
          }
        },
      ),
    );
  }
}