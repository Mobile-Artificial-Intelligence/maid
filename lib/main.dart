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

  MaidProperties props = await MaidProperties.last;

  runApp(
    MaidApp(
      props: props
    )
  );
}

class MaidProperties {
  final AppPreferences appPreferences;
  final Sessions sessions;
  final CharacterCollection characters;
  final ArtificialIntelligence ai;
  final User user;

  const MaidProperties({
    required this.appPreferences, 
    required this.sessions,
    required this.characters,
    required this.ai, 
    required this.user,
  });

  static Future<MaidProperties> get last async {
    final appPreferences = await AppPreferences.last;
    final sessions = await Sessions.last;
    final characters = await CharacterCollection.last;
    final ai = await ArtificialIntelligence.last;
    final user = await User.last;

    return MaidProperties(
      appPreferences: appPreferences, 
      sessions: sessions,
      characters: characters,
      ai: ai,
      user: user
    );
  }
}

class MaidApp extends StatelessWidget {
  final MaidProperties props;

  const MaidApp({
    super.key, 
    required this.props
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => props.appPreferences),
        ChangeNotifierProvider(create: (context) => props.sessions),
        ChangeNotifierProvider(create: (context) => props.characters),
        ChangeNotifierProvider(create: (context) => props.ai),
        ChangeNotifierProvider(create: (context) => props.user),
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
