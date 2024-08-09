import 'package:babylon_tts/babylon_tts.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:maid/ui/desktop/app.dart';
import 'package:maid/ui/mobile/app.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Babylon.init();

  AppPreferences appPreferences = await AppPreferences.last;
  AppData appData = await AppData.last;
  ArtificialIntelligence ai = await ArtificialIntelligence.last;

  runApp(
    MaidApp(
      appPreferences: appPreferences, 
      appData: appData,
      ai: ai
    )
  );
}

class MaidApp extends StatelessWidget {
  final AppPreferences appPreferences;
  final AppData appData;
  final ArtificialIntelligence ai;

  const MaidApp({
    super.key, 
    required this.appPreferences, 
    required this.appData, 
    required this.ai,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appPreferences),
        ChangeNotifierProvider(create: (context) => appData),
        ChangeNotifierProvider(create: (context) => ai),
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